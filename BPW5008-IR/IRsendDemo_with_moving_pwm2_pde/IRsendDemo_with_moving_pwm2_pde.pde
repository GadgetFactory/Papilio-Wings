/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include <IRremote.h>





IRsend irsend;

void setup()
{
  Serial.begin(9600);
  PWM2_LOC = BL0;      //Set PWM2 to B0
  BL1_LOC = AL;        //Set the Button/LED core to AL
  BL1CONTROL_L = 0xa;  //Set the Button outputs to 0xA
}

void loop() {
  //if (Serial.read() != -1) {
    for (int i = 0; i < 3; i++) {
      irsend.sendSony(0xa90, 12); // Sony TV power code
      Serial.println(*(byte *) 0x3000, HEX);
      Serial.println(*(byte *) 0x3002, HEX);      
      delay(100);
    }
  //}
}

