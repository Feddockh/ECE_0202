#include "stm32l476xx.h"
#include "SysClock.h"
#include "UART.h"

#include <string.h>
#include <stdio.h>

// PA.5  <--> Green LED
// PC.13 <--> Blue user button
#define LED_PIN    5
#define BUTTON_PIN 13

/*
void demo_of_printf_scanf(){
	char rxByte;
	printf("Are you enrolled in ECE 202 (Y or N ):\r\n");
	scanf ("%c", &rxByte);
	if (rxByte == 'N' || rxByte == 'n'){
		printf("You should not be here!!!\r\n\r\n");
	}
	else if (rxByte == 'Y' || rxByte == 'y'){
		printf("Welcome!!! \n\r\n\r\n");
	}
}
*/



int main(void){

	System_Clock_Init(); // Switch System Clock = 80 MHz
	UART2_Init(); // Communicate with Tera Term
	
	//demo_of_printf_scanf();

	// ****************************//
	// USER CODE GOES HERE
	// ****************************//
	
	int a = 1;
	R0 -> 0x00000001;
	int b = 2;
	int c = a + b;

	// Configure PA5
	
	RCC -> AHB2ENR &= ~(0x00000005);
	RCC -> AHB2ENR |= 0x00000005;
	
	GPIOA -> MODER &= ~(0x00000C00);
	GPIOA -> MODER |= 0x00000400;
	
	GPIOA -> OTYPER &= ~(0x00000020);
	GPIOA -> OTYPER |= 0x00000000;
	
	GPIOA -> PUPDR &= ~(0x00000C00);
	GPIOA -> PUPDR |= 0x00000000;
	
	// Configure PC13
	GPIOC -> MODER &= ~(0x0C000000);
	GPIOC -> MODER |= 0x00000000;
	
	GPIOC -> PUPDR &= ~(0x0C000000);
	GPIOC -> PUPDR |= 0x00000000;
	
	// Read from PC13 and Set LED light
	// The blue user button is pulled up externally. 
	// The GPIO input is low if the button is pressed down.
	
	while(1) {
		if(GPIOC -> IDR &= 1UL << 13) {
			GPIOA -> ODR ^= 1UL << 5;
		}
	}
	
}
