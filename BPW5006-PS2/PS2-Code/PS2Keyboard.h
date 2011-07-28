/*
  PS2Keyboard.h - PS2Keyboard library
  Copyright (c) 2007 Free Software Foundation.  All right reserved.
  Written by Christian Weichel <info@32leaves.net>

  ** Modified for use with Arduino 13 by L. Abraham Smith, <n3bah@microcompdesign.com> * 
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


#ifndef PS2Keyboard_h
#define PS2Keyboard_h


#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

/*
 * PS2 keyboard "make" codes to check for certain keys.
 */
#define PS2_KC_BREAK  0xf0
#define PS2_KC_ENTER  0x0d
#define PS2_KC_ESC    0x76
#define PS2_KC_KPLUS  0x79
#define PS2_KC_KMINUS 0x7b
#define PS2_KC_KMULTI 0x7c
#define PS2_KC_NUM    0x77
#define PS2_KC_BKSP   0x66


#include "binary.h"
typedef uint8_t boolean;
typedef uint8_t byte;

/**
 * Purpose: Provides an easy access to PS2 keyboards
 * Author:  Christian Weichel
 */
class PS2Keyboard {
  
  private:
    int  m_dataPin;
    byte m_charBuffer;
  
  public:
  	/**
  	 * This constructor does basically nothing. Please call the begin(int,int)
  	 * method before using any other method of this class.
  	 */
  	PS2Keyboard();
    
    /**
     * Starts the keyboard "service" by registering the external interrupt.
     * setting the pin modes correctly and driving those needed to high.
     * The propably best place to call this method is in the setup routine.
     */
    void begin(int dataPin,int irq_pin);
    
    /**
     * Returns true if there is a char to be read, false if not.
     */
    bool available();
    
    /**
     * Returns the char last read from the keyboard. If the user has pressed two
     * keys between calls to this method, only the later one will be availble. Once
     * the char has been read, the buffer will be cleared.
     * If there is no char availble, 0 is returned.
     */
    byte read();
    
};

#endif
