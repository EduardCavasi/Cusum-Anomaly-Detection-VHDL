# Streaming Data Processing & Anomaly Detection  
### Using the Two-Sided CUSUM Algorithm

This project demonstrates a complete workflow for detecting anomalies in temperature sensor data using both software and hardware implementations of the Two-Sided CUSUM algorithm. It includes data preprocessing, binary conversion, AXI4-Stream hardware design, simulation, and FPGA deployment.

---

## 📌 Overview

Modern IoT systems rely on accurate sensor readings, yet sensors can fail, drift, or produce noisy data. This project addresses those challenges by:

- Preprocessing temperature time-series data  
- Implementing a temporal CUSUM anomaly detection algorithm  
- Converting processed values to binary format  
- Building AXI4-Stream compliant hardware components  
- Validating hardware output using a software reference implementation  
- Deploying the final design on a Basys 3 FPGA board  

---

## 🔍 Types of Anomalies Detected

- **Spike anomalies** — sudden and extreme deviations  
- **Constant anomalies** — repeated identical readings  
- **Noise anomalies** — erratic variation due to instability  
- **Drift anomalies** — constant offset due to sensor miscalibration  
- **Gradual/continuous changes** — slow increases, often indicating real phenomena  

---

## 🧮 Two-Sided CUSUM Algorithm

The CUSUM algorithm detects anomalies by tracking cumulative differences between consecutive data points.

### Algorithm Summary

1. Compute the difference:  
   `S_t = x_t - x_(t-1)`

2. Update cumulative sums:  
   - `g⁺_t = max(g⁺_(t-1) + S_t - drift, 0)`  
   - `g⁻_t = max(g⁻_(t-1) - S_t - drift, 0)`

3. If either sum exceeds a threshold, the current sample is labeled as an anomaly.

---

## 🛠️ Hardware Architecture

The hardware implementation uses AXI4-Stream modules, including:

- Adders, subtractors, and comparators  
- Register slices and FIFO buffers for synchronization  
- A broadcaster to distribute `S_t` across parallel paths  
- A threshold detector that outputs anomaly labels  

A final top-level FPGA design integrates:

- The CUSUM detector  
- A ROM storing binary sensor values  
- A 7-segment display  
- A button-driven address incrementer  

---

## 📁 Project Workflow

1. Preprocess the provided temperature sensor dataset  
2. Implement the software CUSUM algorithm and visualize detected anomalies  
3. Convert integer sensor data to binary files  
4. Implement all AXI4-Stream components of the detector  
5. Build and simulate the top-level hardware CUSUM module  
6. Validate hardware outputs against software results  
7. Deploy the final design to the Basys 3 FPGA  

---

## 📚 References

Basseville, M. & Nikiforov, I. *Detection of Abrupt Change – Theory and Application* (1993).  
Erhan et al., *Smart anomaly detection in sensor systems: A multi-perspective review* (2021).  
Giannoni et al., *Anomaly detection models for IoT time series data* (2018).

