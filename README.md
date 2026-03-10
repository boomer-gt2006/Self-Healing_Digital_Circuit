# Self-Healing Digital Circuit with Adaptive Redundancy

## Abstract

Reliability is a critical requirement in modern digital systems used in aerospace electronics, autonomous systems, and safety-critical processors. Conventional digital circuits fail when a hardware module becomes faulty, leading to system failure.

This project proposes a **Self-Healing Digital Circuit Architecture** that detects faults and dynamically activates redundant modules to maintain correct operation. Unlike traditional redundancy systems that permanently replicate hardware, the proposed architecture introduces **Adaptive Redundancy**, where the number of active modules is determined by the current system risk level.

The system monitors runtime parameters such as switching activity and error frequency to estimate system risk. Based on this estimation, the controller dynamically switches between **single-module operation, dual modular redundancy, and triple modular redundancy**. This approach improves system reliability while minimizing unnecessary power consumption.

---

# Problem Statement

Digital systems deployed in **high-reliability environments** such as satellites, autonomous vehicles, and industrial control systems must tolerate hardware faults.

Traditional fault tolerance techniques such as **Triple Modular Redundancy (TMR)** improve reliability but significantly increase **power consumption and hardware area**.

The challenge is to design a **self-healing digital architecture that maintains high reliability while minimizing hardware overhead and power consumption**.

---

# Objectives

* Design a **fault-tolerant digital architecture** capable of recovering from hardware failures.
* Implement **runtime fault detection mechanisms**.
* Develop a **risk estimation unit** that predicts the likelihood of faults.
* Implement **adaptive redundancy control** to activate redundancy only when necessary.
* Evaluate the design based on **power, area, latency, and reliability metrics**.

---

# System Architecture

The proposed architecture consists of the following modules:

1. Processing Units
2. Fault Detection Unit
3. Risk Estimation Engine
4. Adaptive Redundancy Controller
5. Output Selection Logic
6. Fault Injection Framework

---

# High Level Architecture

```
            +--------------------+
Inputs ---->|  Processing Unit 1 |
            +--------------------+
                      |
            +--------------------+
Inputs ---->|  Processing Unit 2 |
            +--------------------+
                      |
            +--------------------+
Inputs ---->|  Processing Unit 3 |
            +--------------------+
                      |
                +-----------+
                | Majority  |
                |  Voter    |
                +-----------+
                      |
                   Output
```

---

# Redundancy Techniques

## Dual Modular Redundancy (DMR)

Two identical modules compute the same operation.

```
Module A
Module B
   |
Comparator
```

If the outputs mismatch, a fault is detected.

---

## Triple Modular Redundancy (TMR)

Three identical modules are used with majority voting.

```
Module A
Module B
Module C
   |
Majority Voter
   |
Output
```

Even if one module fails, the system continues functioning correctly.

TMR is widely used in **spacecraft and mission-critical electronics**.

---

# Adaptive Redundancy

Traditional redundancy always runs all modules simultaneously, which increases power consumption.

This project introduces **Adaptive Redundancy**, where the system dynamically selects the required redundancy level.

| Risk Level  | Active Modules |
| ----------- | -------------- |
| Low Risk    | 1 Module       |
| Medium Risk | 2 Modules      |
| High Risk   | 3 Modules      |

This significantly reduces **power overhead compared to traditional TMR systems**.

---

# Risk Estimation Engine

The **Risk Estimation Unit** determines the probability of system failure using runtime parameters.

## 1. Switching Activity Monitoring

High switching activity increases the probability of glitches and timing failures.

Example logic:

```
if (signal != previous_signal)
    toggle_count++
```

Risk classification:

| Toggle Count | Risk Level |
| ------------ | ---------- |
| < 10         | Low        |
| 10 – 30      | Medium     |
| > 30         | High       |

---

## 2. Error Detection Monitoring

Outputs of redundant modules are compared.

```
compare(ALU1, ALU2)
```

If mismatches occur frequently, system risk increases.

| Error Count | Risk Level |
| ----------- | ---------- |
| 0 – 1       | Low        |
| 2 – 3       | Medium     |
| > 3         | High       |

---

## 3. Temperature Monitoring (Optional)

Higher temperatures increase transistor leakage and timing errors.

| Temperature | Risk Level |
| ----------- | ---------- |
| < 50°C      | Low        |
| 50–70°C     | Medium     |
| > 70°C      | High       |

---

# Adaptive Redundancy Controller

The controller decides how many modules should be active.

Example logic:

```
if risk_score < threshold1
    enable 1 module
else if risk_score < threshold2
    enable 2 modules
else
    enable 3 modules
```

---

# Fault Injection Framework

To test system reliability, faults are artificially injected into the system.

Example fault models:

* Stuck-at-0 faults
* Stuck-at-1 faults
* Bit flips
* Random signal corruption

Example Verilog concept:

```
assign faulty_output = original_output ^ fault_signal;
```

This helps demonstrate the system's **fault recovery capability**.

---

# Unique Research Contributions

This project introduces several ideas that make it more advanced than a traditional redundancy design.

## 1. Adaptive Redundancy Architecture

The system dynamically adjusts redundancy levels based on system risk.

Benefits:

* Lower power consumption
* Improved reliability
* Adaptive fault tolerance

---

## 2. Selective Triple Modular Redundancy

Instead of applying TMR to the entire system, redundancy can be applied only to **critical modules**.

Example:

```
ALU → TMR protected
Control Logic → single module
Memory Interface → DMR
```

This significantly reduces **area and power overhead**.

---

## 3. Runtime Risk Monitoring

The system continuously monitors runtime signals to predict failure probability.

Risk parameters include:

* switching activity
* error frequency
* temperature

---

## 4. Fault Injection Framework

A configurable fault injection system allows systematic testing of the architecture.

This enables evaluation of:

* fault detection rate
* fault masking capability
* recovery latency

---

## 5. Reconfigurable Self-Healing Architecture (Future Work)

In advanced versions, the FPGA could dynamically **reconfigure faulty modules** using partial reconfiguration.

This would allow the system to **replace faulty logic blocks at runtime**.

---

# Evaluation Metrics

The system will be evaluated based on the following metrics.

## Area

Measured using **FPGA LUT utilization**.

## Power

Estimated using **Vivado Power Analysis**.

## Timing

Measured through **critical path delay**.

## Fault Tolerance

Percentage of faults successfully masked.

Example comparison:

| Design              | LUT Usage | Power          | Fault Tolerance  |
| ------------------- | --------- | -------------- | ---------------- |
| Standard ALU        | Low       | Low            | None             |
| TMR ALU             | High      | Higher         | Survives 1 fault |
| Adaptive Redundancy | Moderate  | Lower than TMR | High             |

---

# Implementation Plan

1. Implement a base **8-bit ALU** module.
2. Instantiate multiple redundant ALU modules.
3. Implement a **majority voter** circuit.
4. Implement the **risk estimation engine**.
5. Implement the **adaptive redundancy controller**.
6. Add **fault injection capability**.
7. Simulate the system using a **Verilog testbench**.
8. Synthesize the design on FPGA.
9. Analyze **power and reliability trade-offs**.

---

# Project Structure

```
self-healing-digital-circuit/
│
├── rtl/
│   ├── alu.v
│   ├── majority_voter.v
│   ├── fault_injector.v
│   ├── risk_estimator.v
│   ├── redundancy_controller.v
│   └── top_module.v
│
├── testbench/
│   └── tb_top.v
│
├── docs/
│   └── architecture.md
│
└── README.md
```

---

# Applications

Self-healing architectures are widely used in:

* spacecraft electronics
* autonomous vehicles
* nuclear control systems
* industrial automation
* aerospace computing

---

# Tools

* Verilog HDL
* Xilinx Vivado
* FPGA development board
* Vivado Power Analyzer

---

# Future Improvements

Possible future extensions include:

* Machine learning based fault prediction
* Dynamic voltage and frequency scaling integration
* FPGA partial reconfiguration for runtime repair
* Hardware Trojan detection integration

---

# Conclusion

This project demonstrates a **self-healing digital architecture capable of adaptive fault tolerance**. By dynamically adjusting redundancy levels based on system risk, the design achieves improved reliability while minimizing power overhead.

Such architectures are increasingly important for **next-generation reliable computing systems deployed in safety-critical environments**.
