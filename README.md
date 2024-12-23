# Comunication-protocols-with-vhdl  
Simple project that implements comunication protocols usually used to transmit/recieve data
between devices.
# UART 
Universal Asynchronous Reciever Transmitter, it uses one line for transmition and one line for reception achieving 
half duplex comunication, as in, data can be sent and recieved on separate lines and with different modules.  
To make data transfer possible, some key parameters must be tuned similarly between both sides:  
**DIRECTION:** data is sent as LBS first.  
**BAUDRATE:** it stands for the period of each bit to be transfered each second.  
9600 BAUD is 9600 bits/sec giving a bit period of 104 us.  
**PARITY:** it is used after the data bits are transmitted to check the validity of the data.  
it could be even/odd parity or no parity could be used(the case for the provided design).  
**START/STOP BITS:** used for indicating the start/end of data transmition, the line idles as high until the transmitter sets 
a low pulse to indicate the start of transmition.  
**FLOW CONTROL:** some implementations use special signals to control data flow but these are not implemented.   

The implementation uses AN FSM to indicate the state that the modules are present in.  
the timing for every state is derived from the input clock (system clock) and the baudrate.
these 2 parameters are provided as generics to set up the modules. Meaning that we derive how much clock cycles of the 
system clocks are required to sample/send data on the transmition lines according to each state.  
the transmitter stays at the state  for the whole cycles holding the corresponding output untill the counter rolls over.  
the reciever stays at the state for the same time as the transmitter the difference is at the first state (start bit) the 
reciever samples the the data at the half of the bit times to ensure that the transition robust.

# SPI
Serial Peripheral Interface, this device is faster that UART because it is synchronous.  
The device has 2 modules, the **master** and the **slave**, both of them send and recieve data at the same time, making the 
comunication full duplex, but only when the master wants to, and at the rate that it specifies.  
this is achieved using the following signals:  
**CS:** this line idles high, and when the master wants to comunicate it enables the device that it wants to comunicate with.  
**SCLK:** the clock is used for synchronizationn this makes the speed of transmition very high.  
**MISO:** the master's input and the salve's output.    
**MOSI:** the slave's input and the master's output.  
**CPOL/CPHA:** the device sends data and samples data according to 2 parameters, **clock phase** and **clock polarity**
clock phase represents the 
