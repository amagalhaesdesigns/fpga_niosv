# 🧠 FreeRTOS Temperature Acquisition with ADT7301 (Nios V)

This project demonstrates a **FreeRTOS-based application** running on the **Nios V softcore processor**.  
It performs temperature acquisition from the **ADT7301 SPI sensor**, applies a **moving average filter**,  
and uses **FreeRTOS tasks and queues** for inter-task communication and data handling.

---

## 📘 Overview

### 🎯 Objectives
- Read temperature samples from the **ADT7301** via **SPI**.  
- Apply a **simple moving average filter** to smooth readings.  
- Use **FreeRTOS queues** for producer/consumer task communication.  
- Demonstrate **task scheduling**, **queue synchronization**, and **data processing** in real time.

### 🧩 Hardware Platform
- **FPGA:** Intel® Cyclone V (Qsys Platform)  
- **Processor:** Nios V  
- **Sensor:** ADT7301 (SPI digital temperature sensor)  
- **Interfaces:** SPI, UART (for console output)  

---

## ⚙️ System Architecture

The system is based on a modular **Producer–Consumer** model under **FreeRTOS**, running on the **Nios V** softcore processor.  
Temperature samples are acquired from the **ADT7301** sensor via **SPI**, filtered, queued, and finally displayed through the UART console.


            ┌─────────────────────────────┐
            │       ADT7301 Sensor        │
            │  (SPI Digital Temperature)  │
            └────────────┬────────────────┘
                         │ SPI Bus
                         ▼
            ┌─────────────────────────────┐
            │        Nios V CPU           │
            │ ┌─────────────────────────┐ │
            │ │      FreeRTOS Kernel    │ │
            │ └─────────────────────────┘ │
            │       ▲             ▲       │
            │       │             │       │
            │   ┌────────┐   ┌────────┐   │
            │   │Producer│   │Consumer│   │
            │   │  Task  │   │  Task  │   │
            │   └────────┘   └────────┘   │
            │       │             │       │
            │       ▼             ▼       │
            │   ┌──────────────────────┐  │
            │   │   FreeRTOS Queue     │  │
            │   └──────────────────────┘  │
            └────────────┬────────────────┘
                         │
                         ▼
                 UART Terminal Output
---


## 🧪 How It Works

1. **Initialization**  
   The `main()` function initializes hardware peripherals and creates:
   - A FreeRTOS queue (`xTemperatureQueue`)
   - Two tasks: `vProducerTask` and `vConsumerTask`

2. **Data Acquisition**  
   The **Producer Task** reads data from the ADT7301 via SPI every 100 ms, stores it in a circular buffer,  
   applies a moving average filter, and sends a packet to the queue.

3. **Data Consumption**  
   The **Consumer Task** waits indefinitely (`portMAX_DELAY`) for data to arrive in the queue,  
   then prints the filtered temperature and timestamp via UART.

4. **Typical Output (UART Terminal)**

---

🧑‍💻 Author

Alexandre Magalhães

Embedded Systems & FPGA Engineer

GitHub: amagalhaesdesigns
