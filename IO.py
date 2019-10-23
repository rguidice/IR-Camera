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
from datetime import datetime
import cv2
import os

class irCam:
    def __init__(self):
        self.IR_pin = 35
        self.vid_count = 1
        
        #initialize GPIO settings
        GPIO.setmode(GPIO.BOARD)
        GPIO.setwarnings(False)
        GPIO.setup(self.IR_pin,GPIO.IN,pull_up_down=GPIO.PUD_DOWN)
        
        #create directory named with date and time to store video files in
        self.cwd = os.getcwd()
        now = datetime.now()
        self.video_dir = now.strftime("%m-%d-%Y_%H:%M:%S")
        os.mkdir(self.video_dir)
        
        print("-------------------------------------------------------")

    def main(self):
        while True:
            value = GPIO.input(self.IR_pin)
            print(value)
            if value != 0:
                self.record()
                time.sleep(5)
            else:
                print("nothing found")
                time.sleep(1)
                
    def record(self):
        cam = cv2.VideoCapture(0)
        
        #Create video codec and create VideoWriter object (AVI file format, 640x480 resolution, 10fps)
        fourcc = cv2.VideoWriter_fourcc(*'XVID')
        curr_time = datetime.now().strftime("_%H:%M:%S")
        output_str = str(self.vid_count) + curr_time + '.avi'
        output = cv2.VideoWriter(output_str,fourcc,10.0,(640,480))
        
        #Get starting time for video time comparison
        origTime = time.process_time()
        print("Camera recording")

        #Record for about 25 seconds (origTime + 8)
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
        self.vid_count = self.vid_count+1
        os.rename(self.cwd+"/"+output_str, self.cwd+"/"+self.video_dir+"/"+output_str)
        return

irCam1 = irCam()
irCam1.main()