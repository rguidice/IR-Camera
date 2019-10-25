## IR-Camera

Description: Written to take in IR sensor input from Tiva microcontroller and start recording video via a webcam controlled by a Raspberry Pi.

General Overview of Structure:
1. IR sensor is 0/3.3V output connected to Port E on the Tiva microcontroller.
2. Microcontroller is running Lab9.s, and uses a SysTick interrupt to check the first bit of Port E once per second. If it is a 1, it gets copied to Port B, the output port.
3. The Raspberry Pi is connected to Port B on pin 35 and has IO.py running. IO.py constantly checks pin 35, and if it's high, will start recording via the attached webcam. It records for a pre-determined amount of time before checking if pin 35 is still high. If it is, it will continue recording, otherwise it will write the video and go back to polling pin 35.
     
Components used: 
- Tiva Microcontroller
- Raspberry Pi 3
- Creative Labs VF0415 Webcam
- Gowoops HC-SR501 PIR Motion Sensor (http://osoyoo.com/2017/05/27/hc-sr501-pir-motion-sensor/)

Written for Lab 9 of Colorado State University's ECE251 course, taught by Dr. Bill Eads.
