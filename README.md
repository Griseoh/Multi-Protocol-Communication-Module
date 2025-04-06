# 🚀 Multi-Protocol Communication Module  

This repository contains Verilog HDL modules and Constraint file for FPGA implementation of a **multi-protocol communication module** that supports **SPI, I2C, and UART** for seamless data transmission between transmitter and receiver nodes.  

## 📌 Features  
✅ Supports **SPI, I2C, and UART** protocols  
✅ Efficient **Modular** design  
✅ Modular **Verilog HDL implementation**  
✅ Simulated & verified with **waveforms**  

---

## 📜 Architecture Overview  

### 🔷 Top Module Schematic (Pre Synthesis and Implementation)  
📷 ![Top Module Pre](https://github.com/user-attachments/assets/80e1feda-105c-48ca-b6c0-18d3519ead0d)
  
### 🔷 Top Module Schematic (Post Synthesis and Implementation)
📷 ![Top Module Post](https://github.com/user-attachments/assets/91bfc3d1-c89a-42aa-b852-7db6c061cc8c)

---

## 🔗 Protocol-Specific Modules  

### 🟠 SPI Sub-Module  
📷 **Schematic:**  
![SPI Module](https://github.com/user-attachments/assets/b795d015-db60-4032-bb67-8a0133f3c180)

📉 **Waveform:**  
![SPI Waveform](https://github.com/user-attachments/assets/4951bfaa-4919-4f0d-b7ac-8f4c76f9c13b)  

### 🔵 UART Sub-Module  
📷 **Schematic:**  
![UART Module](https://github.com/user-attachments/assets/ccb0d768-219c-413c-9f7a-214ce1879051)

📉 **Waveform:**  
![UART Waveform](https://github.com/user-attachments/assets/a533fa12-e802-47bc-9758-3e7d51735dad)  

### 🟢 I2C Sub-Module  
📷 **Schematic:**  
![I2C Module](https://github.com/user-attachments/assets/3d2d4210-653b-4185-a03d-dd4c8459fb82)

📉 **Waveform:**  
![I2C Waveform](https://github.com/user-attachments/assets/bdc82d01-b63d-4bdd-8e29-df1909d07604)

---

## 🔗 Target FPGA : Xilinx Pynq Z2
📷 ![image](https://github.com/user-attachments/assets/70da1324-9546-4a4d-b864-ac69601ba983)
## 📜 Specifications

| Category         | Feature / Specification                                                                 |
|------------------|------------------------------------------------------------------------------------------|
| **FPGA**         | Zynq-7000 SoC XC7Z020-1CLG400C                                                           |
| **I/O Interfaces** | - USB-JTAG Programming Circuitry  <br> - USB OTG 2.0  <br> - USB-UART Bridge <br> - 10/100/1G Ethernet <br> - HDMI Input <br> - HDMI Output <br> - I2S with 24-bit DAC (3.5mm TRRS jack) <br> - Line-in (3.5mm jack) |
| **Memory**       | - 512 MB DDR3 (16-bit bus @ 1050 Mbps) <br> - 128 Mbit Quad-SPI Flash <br> - Micro SD Card Connector |
| **Switches & LEDs** | - 2 Slide Switches <br> - 2 RGB LEDs <br> - 4 LEDs <br> - 4 Push-Buttons              |
| **Clocks**       | - 125 MHz for Programmable Logic (PL) <br> - 50 MHz for Processing System (PS)          |
| **Expansion Ports** | - 2 Pmod Ports (16 Total FPGA I/O, 8 shared with Raspberry Pi Connector) <br> - 1 Arduino Shield Connector (24 Total FPGA I/O) <br> - 6 Single-ended 0–3.3V Analog Inputs (XADC) |
| **Raspberry Pi Connector** | 28 Total FPGA I/O (8 shared with Pmod A port)                                 |
| **Power Monitoring** | Active monitoring of power supply currents and voltages                              |

