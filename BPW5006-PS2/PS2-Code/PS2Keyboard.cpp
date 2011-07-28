/*
  PS2Keyboard.cpp - PS2Keyboard library
  Copyright (c) 2007 Free Software Foundation.  All right reserved.
  Written by Christian Weichel <info@32leaves.net>

  ** Modified for use beginning with Arduino 13 by L. Abraham Smith, <n3bah@microcompdesign.com> * 
  ** Modified for easy interrup pin assignement on method begin(datapin,irq_pin). Cuningan <cuninganreset@gmail.com> **

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include "WProgram.h"
#include "PS2Keyboard.h"
#include "binary.h"
typedef uint8_t boolean;
typedef uint8_t byte;


/*
 * The lookup table used by the read() method. Change this in order to
 * support more or different keys. But be aware that the more keys are in
 * this table, the longer the lookup will take and the more space will be
 * consumed.
 * 
 * The CURRENT modified implementation understands the numblock numbers, capital letters, numerals and basic punctuation.
 * Shifted symbols are not implemented at this time. These modifications by L. Abraham Smith, <n3bah@microcompdesign.com> 
 *
 * See
 * http://www.computer-engineering.org/ps2keyboard/scancodes2.html for a list
 * of possible scancodes.
 */
#define PS2_KC_LUT_CAPACITY 51
PROGMEM prog_uchar PS2_KC_LUT_DATA[PS2_KC_LUT_CAPACITY] = {0x70, 0x69, 0x72, 0x7a, 0x6b, 0x73, 0x74, 0x6c, 0x75, 0x7d, 0x1c, 0x32, 0x21, 0x23, 0x24, 0x2b, 0x34, 0x33, 0x43, 0x3b, 0x42, 0x4b, 0x3a, 0x31, 0x44, 0x4d, 0x15, 0x2d, 0x1b, 0x2c, 0x3c, 0x2a, 0x1d, 0x22, 0x35, 0x1a, 0x16, 0x1e, 0x26, 0x25, 0x2e, 0x36, 0x3d, 0x3e, 0x46, 0x45, 0x29, 0x41, 0x49, 0x4a, 0X5A};
PROGMEM prog_uchar PS2_KC_LUT_CHAR[PS2_KC_LUT_CAPACITY] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ' ', ',', '.', '/', 13};


/*
 * I do know this is so uncool, but I just don't see a way arround it
 * REALLY BAD STUFF AHEAD
 *
 * The variables are used for internal status management of the ISR. The're
 * not kept in the object instance because the ISR has to be as fast as anyhow
 * possible. So the overhead of a CPP method call is to be avoided.
 *
 * PLEASE DO NOT REFER TO THESE VARIABLES IN YOUR CODE AS THEY MIGHT VANISH SOME
 * HAPPY DAY.
 */
int ps2Keyboard_DataPin;
byte ps2Keyboard_CurrentBuffer;
volatile byte ps2Keyboard_CharBuffer;
byte ps2Keyboard_BufferPos;
bool ps2Keyboard_BreakActive;


// The ISR for the external interrupt
void ps2interrupt (void) {
  int value = digitalRead(ps2Keyboard_DataPin);
  
  if(ps2Keyboard_BufferPos > 0 && ps2Keyboard_BufferPos < 11) {
    ps2Keyboard_CurrentBuffer |= (value << (ps2Keyboard_BufferPos - 1));
  }
  
  ps2Keyboard_BufferPos++;
  
  if(ps2Keyboard_BufferPos == 11) {
    if(ps2Keyboard_CurrentBuffer == PS2_KC_BREAK) {
      ps2Keyboard_BreakActive = true;
    } else if(ps2Keyboard_BreakActive) {
      ps2Keyboard_BreakActive = false;
    } else {
      ps2Keyboard_CharBuffer = ps2Keyboard_CurrentBuffer;
      
    }
    ps2Keyboard_CurrentBuffer = 0;
    ps2Keyboard_BufferPos = 0;
  }
}

PS2Keyboard::PS2Keyboard() {
  // nothing to do here	
}

void PS2Keyboard::begin(int dataPin,int irq_pin) {
  // Prepare the global variables
  ps2Keyboard_DataPin = dataPin;
  ps2Keyboard_CurrentBuffer = 0;
  ps2Keyboard_CharBuffer = 0;
  ps2Keyboard_BufferPos = 0;
  ps2Keyboard_BreakActive = false;

  // initialize the pins
  pinMode(irq_pin, INPUT);
  digitalWrite(irq_pin, HIGH);
  pinMode(dataPin, INPUT);
  digitalWrite(dataPin, HIGH);
  
  switch(irq_pin)
  {
	case 0:
	break;
	
	case 1:
	break;
	
	case 2:
	irq_pin=0;
	break;
	
	case 3:
	irq_pin = 1;
	break;
	
	default:
	irq_pin=0;
	break;
  }
  attachInterrupt(irq_pin, ps2interrupt, FALLING);
#if 0
  // Global Enable INT1 interrupt
  EIMSK |= ( 1 << INT1);
  // Falling edge triggers interrupt
  EICRA |= (0 << ISC10) | (1 << ISC11);
#endif
}



bool PS2Keyboard::available() {
  return ps2Keyboard_CharBuffer != 0;
}

byte PS2Keyboard::read() {
  byte result = ps2Keyboard_CharBuffer;
  
  for(int i = 0; i < PS2_KC_LUT_CAPACITY; i++) {
    if(ps2Keyboard_CharBuffer == pgm_read_byte_near(PS2_KC_LUT_DATA + i)) {
      result = pgm_read_byte_near(PS2_KC_LUT_CHAR + i);
    }
  }
  ps2Keyboard_CharBuffer = 0;
  
  return result;
}
