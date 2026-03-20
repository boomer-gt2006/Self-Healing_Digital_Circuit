#!/usr/bin/env python3
"""
Power Estimation Tool - Analyzes VCD files to estimate dynamic power consumption
using switching activity factors and architectural parameters.

Methodology:
  Dynamic Power = C * V^2 * F * A
  where:
    C = estimated capacitance (pF, derived from logic element counts)
    V = supply voltage (1.0V for Artix-7)
    F = clock frequency (MHz)
    A = activity factor (transitions / 2 / total_transitions)
  
  Static Power = estimated leakage (mW, derived from element counts)
"""

import re
import os
from pathlib import Path
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, Tuple

@dataclass
class ModuleUtilization:
    """Resource utilization metrics for a module."""
    name: str
    luts: int
    ffs: int
    dsps: int
    brams: int
    
    def total_logic_cells(self) -> int:
        """Total logic cells (LUTs + FFs)."""
        return self.luts + self.ffs
    
    def estimated_capacitance_pf(self) -> float:
        """Estimate capacitance in pF based on logic element count.
        
        Empirical model for Xilinx Artix-7:
        - LUT: ~2.5 pF per LUT
        - FF: ~3.0 pF per FF (includes interconnect)
        - Routing overhead: +15% of logic capacitance
        """
        logic_cap = (self.luts * 2.5) + (self.ffs * 3.0)
        routing_overhead = logic_cap * 0.15
        return logic_cap + routing_overhead
    
    def estimated_leakage_mw(self, temp_c: float = 27.0) -> float:
        """Estimate leakage power in mW.
        
        Empirical temperature-dependent model for Artix-7:
        - Base leakage: 0.15 mW per 100 logic cells
        - Temperature coefficient: +0.003 mW per °C per 100 cells
        """
        base_leakage = (self.total_logic_cells() / 100) * 0.15
        temp_delta = temp_c - 27.0
        temp_leakage = (self.total_logic_cells() / 100) * 0.003 * temp_delta
        return max(base_leakage + temp_leakage, 0.01)  # Minimum 10 µW


class VCDParser:
    """Parse Verilog Value Change Dump (VCD) files and extract switching activity."""
    
    def __init__(self, vcd_path: str):
        self.vcd_path = vcd_path
        self.timescale = 1  # Default 1 ps
        self.signals = defaultdict(list)  # signal_name -> [(time, value), ...]
        self.start_time = None
        self.end_time = None
        self.parse_errors = []
    
    def parse(self) -> bool:
        """Parse VCD file and populate signal records."""
        try:
            with open(self.vcd_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
            
            state = 'header'
            signal_map = {}  # identifier -> signal_name
            
            for i, line in enumerate(lines):
                line = line.strip()
                
                # Parse header
                if state == 'header':
                    if line.startswith('$timescale'):
                        match = re.search(r'\d+\s+([a-z]+)', line)
                        if match:
                            unit = match.group(1)
                            timescale_map = {'s': 1e12, 'ms': 1e9, 'us': 1e6, 
                                            'ns': 1e3, 'ps': 1, 'fs': 1e-3}
                            self.timescale = timescale_map.get(unit, 1)
                    
                    elif line.startswith('$var'):
                        parts = line.split()
                        if len(parts) >= 4:
                            var_type, var_size, identifier, var_name = parts[1], parts[2], parts[3], parts[4]
                            signal_map[identifier] = var_name
                    
                    elif line.startswith('$enddefinitions'):
                        state = 'data'
                        continue
                
                # Parse value changes
                elif state == 'data':
                    if line.startswith('#'):
                        try:
                            current_time = int(line[1:])
                        except ValueError:
                            continue
                    
                    elif line and not line.startswith('$'):
                        # Parse value change: '[01xzXZ]<identifier>' or '<value> <identifier>'
                        match = re.match(r'^([01xzXZ])([a-zA-Z0-9!]+)$', line)
                        if match:
                            value, identifier = match.groups()
                            if identifier in signal_map:
                                signal_name = signal_map[identifier]
                                self.signals[signal_name].append((current_time, value))
                                
                                if self.start_time is None:
                                    self.start_time = current_time
                                self.end_time = current_time
            
            return len(self.signals) > 0
        
        except Exception as e:
            self.parse_errors.append(f"VCD parse error: {e}")
            return False
    
    def calculate_activity_factor(self, signal_name: str) -> Tuple[int, float]:
        """Calculate switching activity factor for a signal.
        
        Returns: (transition_count, activity_factor)
        """
        if signal_name not in self.signals:
            return 0, 0.0
        
        transitions = len(self.signals[signal_name])
        if self.end_time and self.start_time is not None:
            total_time_units = self.end_time - self.start_time
            if total_time_units > 0:
                activity_factor = transitions / (2 * total_time_units)
                return transitions, activity_factor
        
        return transitions, 0.0
    
    def get_signal_statistics(self) -> Dict[str, Tuple[int, float, int]]:
        """Get statistics for all signals.
        
        Returns: signal_name -> (transitions, activity_factor, bit_width_est)
        """
        stats = {}
        for signal_name in self.signals:
            transitions, activity = self.calculate_activity_factor(signal_name)
            # Estimate bit width from signal name patterns
            bit_width = self._estimate_bit_width(signal_name)
            stats[signal_name] = (transitions, activity, bit_width)
        return stats
    
    def _estimate_bit_width(self, signal_name: str) -> int:
        """Estimate bit width from signal name patterns."""
        # Common patterns: [7:0], 8-bit, _8b, etc.
        match = re.search(r'\[(\d+):0\]|\[(\d+)\]|_(\d+)b|(\d+)bit', signal_name)
        if match:
            for group in match.groups():
                if group:
                    return int(group) + 1
        # Default: 1 bit
        return 1
    
    def get_aggregated_activity(self, prefix: str = None) -> float:
        """Calculate aggregated switching activity factor.
        
        If prefix is provided, only consider signals matching that prefix.
        """
        total_transitions = 0
        total_capacity = 0
        
        for signal_name, changes in self.signals.items():
            if prefix and not signal_name.startswith(prefix):
                continue
            
            bit_width = self._estimate_bit_width(signal_name)
            total_transitions += len(changes) * bit_width
            
            # Assume each 1-bit signal has ~5 fF capacitance
            total_capacity += bit_width * 5
        
        if total_capacity > 0 and self.end_time and self.start_time is not None:
            total_time_units = self.end_time - self.start_time
            if total_time_units > 0:
                return total_transitions / (2 * total_time_units)
        
        return 0.0


class PowerEstimator:
    """Estimate power consumption from architectural parameters and activity."""
    
    def __init__(self, utilization: ModuleUtilization, 
                 frequency_mhz: float = 50.0, 
                 supply_voltage: float = 1.0,
                 temp_celsius: float = 27.0):
        self.util = utilization
        self.frequency_mhz = frequency_mhz
        self.supply_voltage = supply_voltage
        self.temp_celsius = temp_celsius
    
    def estimate_dynamic_power(self, activity_factor: float) -> float:
        """Estimate dynamic power in mW.
        
        P_dynamic = C * V^2 * F * A
        where A is normalized activity factor (0.0 to 1.0)
        """
        C_pf = self.util.estimated_capacitance_pf()
        V_squared = self.supply_voltage ** 2
        F_ghz = self.frequency_mhz / 1000.0
        
        # Convert: pF * V^2 * GHz = (1e-12 * V^2 * 1e9 * MHz/1000) mW
        # = V^2 * MHz * 1e-6 * pF mW
        dynamic_power = C_pf * V_squared * F_ghz * activity_factor
        
        return dynamic_power
    
    def estimate_static_power(self) -> float:
        """Estimate static (leakage) power in mW."""
        return self.util.estimated_leakage_mw(self.temp_celsius)
    
    def estimate_total_power(self, activity_factor: float) -> float:
        """Estimate total power (dynamic + static) in mW."""
        dynamic = self.estimate_dynamic_power(activity_factor)
        static = self.estimate_static_power()
        return dynamic + static
    
    def estimate_energy(self, activity_factor: float, 
                       simulation_time_us: float) -> float:
        """Estimate energy consumption in µJ.
        
        E = P * t, where t is simulation time in µs
        """
        power_mw = self.estimate_total_power(activity_factor)
        energy_uj = power_mw * simulation_time_us / 1000.0
        return energy_uj


class PowerComparison:
    """Compare power consumption across multiple designs."""
    
    designs = {
        'alu': ModuleUtilization('alu', 36, 9, 0, 0),
        'fault_injector': ModuleUtilization('fault_injector', 8, 0, 0, 0),
        'majority_voter': ModuleUtilization('majority_voter', 13, 0, 0, 0),
        'penta_voter': ModuleUtilization('penta_voter', 24, 0, 0, 0),
        'risk_estimator': ModuleUtilization('risk_estimator', 27, 33, 0, 0),
        'redundancy_controller': ModuleUtilization('redundancy_controller', 2, 3, 0, 0),
        'top_dmr': ModuleUtilization('top_dmr', 54, 9, 0, 0),
        'top_tmr': ModuleUtilization('top_tmr', 87, 9, 0, 0),
        'top_adaptive': ModuleUtilization('top_adaptive', 173, 44, 0, 0),
    }
    
    @staticmethod
    def generate_report(vcd_adaptive: str, vcd_traditional: str = None) -> str:
        """Generate comprehensive power comparison report."""
        report = []
        report.append("=" * 100)
        report.append("POWER ESTIMATION AND COMPARISON REPORT")
        report.append("=" * 100)
        report.append(f"\nTimestamp: {Path(vcd_adaptive).stat().st_mtime}")
        report.append(f"Simulation Tool: Vivado xsim")
        report.append(f"Target Platform: Xilinx Artix-7 35T (xc7a35tcpg236-1)")
        report.append(f"Supply Voltage: 1.0 V")
        report.append(f"Temperature: 27°C (typical)")
        
        # Parse VCD files
        report.append("\n" + "=" * 100)
        report.append("STEP 1: DESIGN DATA")
        report.append("=" * 100)
        
        for design_name, util in PowerComparison.designs.items():
            report.append(f"\n{design_name.upper()}:")
            report.append(f"  LUTs: {util.luts:6d} | FFs: {util.ffs:6d} | "
                         f"Total Logic: {util.total_logic_cells():6d}")
            report.append(f"  Estimated Capacitance: {util.estimated_capacitance_pf():8.2f} pF")
            report.append(f"  Estimated Leakage Power: {util.estimated_leakage_mw():8.3f} mW")
        
        # Parse adaptive VCD
        vcd_ada = VCDParser(vcd_adaptive)
        if vcd_ada.parse():
            report.append("\n" + "=" * 100)
            report.append("STEP 2: VCD ANALYSIS (ADAPTIVE DESIGN)")
            report.append("=" * 100)
            
            report.append(f"\nFile: {os.path.basename(vcd_adaptive)}")
            report.append(f"Signals captured: {len(vcd_ada.signals)}")
            report.append(f"Simulation time: {vcd_ada.end_time} ps (timescale: {vcd_ada.timescale} ps/unit)")
            
            if vcd_ada.parse_errors:
                report.append(f"Warnings: {len(vcd_ada.parse_errors)}")
            
            stats = vcd_ada.get_signal_statistics()
            
            report.append("\nTop 20 Most Active Signals:")
            report.append(f"{'Signal Name':<40} {'Transitions':>12} {'Activity Factor':>18}")
            report.append("-" * 70)
            
            sorted_signals = sorted(stats.items(), 
                                   key=lambda x: x[1][0], 
                                   reverse=True)[:20]
            for signal_name, (transitions, activity, width) in sorted_signals:
                report.append(f"{signal_name:<40} {transitions:>12d} {activity:>18.6f}")
            
            # Calculate aggregated activity
            agg_activity = vcd_ada.get_aggregated_activity()
            report.append(f"\nAggregated activity factor: {agg_activity:.6f}")
        else:
            report.append(f"\nERROR: Failed to parse {vcd_adaptive}")
        
        # Parse traditional VCD if provided
        if vcd_traditional and os.path.exists(vcd_traditional):
            vcd_trad = VCDParser(vcd_traditional)
            if vcd_trad.parse():
                report.append("\n" + "=" * 100)
                report.append("STEP 3: VCD ANALYSIS (TRADITIONAL DESIGN)")
                report.append("=" * 100)
                
                report.append(f"\nFile: {os.path.basename(vcd_traditional)}")
                report.append(f"Signals captured: {len(vcd_trad.signals)}")
                report.append(f"Simulation time: {vcd_trad.end_time} ps")
                
                stats_trad = vcd_trad.get_signal_statistics()
                
                report.append("\nTop 20 Most Active Signals:")
                report.append(f"{'Signal Name':<40} {'Transitions':>12} {'Activity Factor':>18}")
                report.append("-" * 70)
                
                sorted_signals_trad = sorted(stats_trad.items(), 
                                            key=lambda x: x[1][0], 
                                            reverse=True)[:20]
                for signal_name, (transitions, activity, width) in sorted_signals_trad:
                    report.append(f"{signal_name:<40} {transitions:>12d} {activity:>18.6f}")
                
                agg_activity_trad = vcd_trad.get_aggregated_activity()
                report.append(f"\nAggregated activity factor: {agg_activity_trad:.6f}")
        
        # Power Estimation Summary
        report.append("\n" + "=" * 100)
        report.append("STEP 4: POWER ESTIMATION SUMMARY")
        report.append("=" * 100)
        
        if vcd_ada.parse():
            agg_activity = vcd_ada.get_aggregated_activity()
            sim_time_us = (vcd_ada.end_time - vcd_ada.start_time) / 1e6 if vcd_ada.start_time else 0
            
            for design_name in ['alu', 'top_dmr', 'top_tmr', 'top_adaptive']:
                if design_name in PowerComparison.designs:
                    util = PowerComparison.designs[design_name]
                    estimator = PowerEstimator(util)
                    
                    dynamic = estimator.estimate_dynamic_power(agg_activity)
                    static = estimator.estimate_static_power()
                    total = dynamic + static
                    energy = estimator.estimate_energy(agg_activity, sim_time_us)
                    
                    report.append(f"\n{design_name.upper()}:")
                    report.append(f"  Static (Leakage) Power: {static:8.3f} mW")
                    report.append(f"  Dynamic Power (α={agg_activity:.4f}): {dynamic:8.3f} mW")
                    report.append(f"  Total Power: {total:8.3f} mW")
                    report.append(f"  Estimated Energy (sim): {energy:8.3f} µJ")
        
        # Comparison and Analysis
        report.append("\n" + "=" * 100)
        report.append("STEP 5: ARCHITECTURE COMPARISON")
        report.append("=" * 100)
        
        alu = PowerComparison.designs['alu']
        top_dmr = PowerComparison.designs['top_dmr']
        top_tmr = PowerComparison.designs['top_tmr']
        top_adaptive = PowerComparison.designs['top_adaptive']
        
        report.append(f"\nArea Overhead Analysis:")
        report.append(f"  Single ALU: {alu.total_logic_cells():4d} cells")
        report.append(f"  DMR (2 ALU + voter): {top_dmr.total_logic_cells():4d} cells "
                     f"({100*top_dmr.total_logic_cells()/alu.total_logic_cells():.1f}x)")
        report.append(f"  TMR (3 ALU + voter): {top_tmr.total_logic_cells():4d} cells "
                     f"({100*top_tmr.total_logic_cells()/alu.total_logic_cells():.1f}x)")
        report.append(f"  Adaptive (5 ALU + voters + controller): {top_adaptive.total_logic_cells():4d} cells "
                     f"({100*top_adaptive.total_logic_cells()/alu.total_logic_cells():.1f}x)")
        
        report.append(f"\nStatic Power Comparison (at 27°C):")
        est_alu = PowerEstimator(alu)
        est_dmr = PowerEstimator(top_dmr)
        est_tmr = PowerEstimator(top_tmr)
        est_adaptive = PowerEstimator(top_adaptive)
        
        static_alu = est_alu.estimate_static_power()
        static_dmr = est_dmr.estimate_static_power()
        static_tmr = est_tmr.estimate_static_power()
        static_adaptive = est_adaptive.estimate_static_power()
        
        report.append(f"  Single ALU: {static_alu:8.3f} mW")
        report.append(f"  DMR: {static_dmr:8.3f} mW (overhead: +{100*(static_dmr/static_alu-1):.1f}%)")
        report.append(f"  TMR: {static_tmr:8.3f} mW (overhead: +{100*(static_tmr/static_alu-1):.1f}%)")
        report.append(f"  Adaptive: {static_adaptive:8.3f} mW (overhead: +{100*(static_adaptive/static_alu-1):.1f}%)")
        
        report.append(f"\nKey Insights:")
        report.append(f"  • Adaptive design uses {top_adaptive.luts} LUTs vs {alu.luts} for single ALU")
        report.append(f"  • 5 ALUs enable 2-fault tolerance (vs 1 fault in TMR, 0 in DMR)")
        report.append(f"  • Penta voter (24 LUTs) vs Majority voter (13 LUTs, +85% LUTs)")
        report.append(f"  • Risk estimator adds adaptive control overhead: {27+33} cells")
        report.append(f"  • Static power scales linearly with logic cell count")
        report.append(f"  • Dynamic power depends on switching activity and capacitance")
        
        report.append("\n" + "=" * 100)
        report.append("END OF REPORT")
        report.append("=" * 100)
        
        return "\n".join(report)


if __name__ == '__main__':
    import sys
    
    workspace_root = Path(__file__).parent.parent
    vcd_adaptive = workspace_root / 'tb_adaptive.vcd'
    vcd_traditional = workspace_root / 'tb_traditional.vcd'
    
    print("VCD Power Estimation Tool")
    print("=" * 100)
    print(f"Workspace: {workspace_root}")
    print(f"Checking for VCD files...")
    print(f"  Adaptive: {vcd_adaptive.exists()}")
    print(f"  Traditional: {vcd_traditional.exists()}")
    print()
    
    if vcd_adaptive.exists():
        report = PowerComparison.generate_report(
            str(vcd_adaptive),
            str(vcd_traditional) if vcd_traditional.exists() else None
        )
        
        print(report)
        
        # Save report to file
        report_path = Path(__file__).parent / 'power_estimation_report.txt'
        with open(report_path, 'w') as f:
            f.write(report)
        
        print(f"\nReport saved to: {report_path}")
    else:
        print(f"ERROR: VCD file not found: {vcd_adaptive}")
        sys.exit(1)
