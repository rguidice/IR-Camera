#-----------------------------------------------------------------------------------------------------------------------------------------
# Author: Ryan Guidice
# Date: 10/12/2019
# Description:
#     Written to take in sensor input from Tiva microcontroller and start recording video via a webcam
#     Materials used:
#         Tiva Microcontroller
#         Raspberry Pi 3
#         Creative Labs VF0415
#         Gowoops HC-SR501 PIR Motion Sensor (http://osoyoo.com/2017/05/27/hc-sr501-pir-motion-sensor/)
#
# Originally written as part of Lab 9 for Colorado State University's ECE251 course, taught by Dr. Bill Eads.
#-----------------------------------------------------------------------------------------------------------------------------------------
import RPi.GPIO as GPIO
import time
import cv2

IR_pin = 35

def init():
    GPIO.setmode(GPIO.BOARD)
    GPIO.setwarnings(False)
    GPIO.setup(IR_pin,GPIO.IN,pull_up_down=GPIO.PUD_DOWN)
    print("-------------------------------------------------------")

def main():
    while True:
        value = GPIO.input(IR_pin)
        print(value)
        if value != 0:
            record()
            time.sleep(5)
        else:
            print("nothing found")
            time.sleep(5)
            
def record():
    cam = cv2.VideoCapture(0)
    
    #Create video codec and create VideoWriter object (AVI file format, 640x480 resolution, 15fps)
    fourcc = cv2.VideoWriter_fourcc(*'XVID')
    output = cv2.VideoWriter('output.avi',fourcc,15.0,(640,480))
    
    #Get starting time for video time comparison
    origTime = time.process_time()
    print("Camera recording")

    while(cam.isOpened()):
        res, frame = cam.read()
        if res == True:
            output.write(frame)
            cv2.imshow("camera", frame)
            currTime = time.process_time()
            if currTime > (origTime + 5):
                break
        else:
            break

    print("Camera done recording")
    cam.release()
    output.release()
    cv2.destroyAllWindows()
    return

init()
main()
GPIO.cleanup()