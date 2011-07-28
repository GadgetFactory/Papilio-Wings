/*
  This is the original example of using the PS2Keyboard library with arduino, 
  but for my particular project i need to edit the original liubrary and add the posibility
  of changing the interrupt pin in the keyboard.begin() function.
  
  In original form you only can adjust the datapin
    
      keyboard.begin(datapin);
      
  Now you can adjust the irq pin
  
      keyboard.begin(datapin,irq_pin);
      
  I have edited the file for Arduino Duemilanove with Atmega 328P, that only have 2 interrupts pin
  and you can put things like this:
  
    keyboard.begin(datapin,0); // this assign irq pin to Digital pin 2.
    keyboard.begin(datapin,1); // this assign irq pin to Digital pin 3.
    keyboard.begin(datapin,2); // this assign irq pin to Digital pin 2.
    keyboard.begin(datapin,3); // this assign irq pin to Digital pin 3.
    
  In case you enter another values this initialice automatically to Digital Pin 2.
  
  for more information you can read the original wiki in arduino.cc
  
  Like the Original library and example this is under GPL license.
  
  Modified by Cuninganreset@gmail.com on 2010-03-22
*/
   
#include <PS2Keyboard.h>

#define DATA_PIN 9
#define IRQ_PIN 2

PS2Keyboard keyboard;

void setup() {
  keyboard.begin(DATA_PIN,IRQ_PIN);

  Serial.begin(9600);
  Serial.println("hi");
  delay(1000);
}

void loop() {
  if(keyboard.available()) {
    byte dat = keyboard.read();
    byte val = dat - '0';
    /*
      If you want to se another characters than onlyu numbers you can make something like this:
      
        Serial.print(val);
        
    */
    if(val >= 0 && val <= 9) {
      Serial.print(val, DEC);
    } else if(dat == PS2_KC_ENTER) {
      Serial.println();
    } else if(dat == PS2_KC_ESC) {
      Serial.println("[ESC]");
    } 
  }
}
