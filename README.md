# CDC
A set of modules for clock domain crossing on FPGAs


# Tasks:
- Create testbench. Due 7/15/2025
  - Must include the following cases:
    - clock signals syncing up at least three times but not every time
    - 10 times frequency difference
      - Faster TX
      - Faster RX
    - 1.001 times frequency difference
      - Faster TX
      - Faster RX
    - Equal frequencies
  - Must attempt to send the following data:
    - 0xdeadbeef
    - 0xcoffee
    - 0x31415926535897932384626433832795028841971693993751058209749445923
  - Must tell the user whether the data passed or not
  - Must test a module with at least the following signals:
    - input TXData, TXClk, RXClk,
    - output RXData
- Create module. Due 7/16/2025
  - Must properly send all data 
- Physically test module on an FPGA. Due 7/17/2025
