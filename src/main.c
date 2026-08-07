#define STM32F446xx

#include <stdint.h>
#include "../external/stm32f4xx.h"
#include "../external/stm32f446xx.h"

// cppcheck-suppress unusedFunction
void SystemInit(void) {
    // Need for compiling
}

// August 5: blinky test on test_led = pa5

// delay function
void delay(volatile uint32_t countdown) {
	while(countdown--) {}
}

int main(void) {

	// turn on the clock for Port A
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;

	// configure pin mode to digital output for pin 5
	// first, reset the two bits to 00 (don't want previous information)
	// second, set those two bits to the proper setting (output is 01)
	GPIOA->MODER &= ~(0b11 << (5 * 2));
	GPIOA->MODER |= (0b01 << (5 * 2));

	// use register GPIOA_ODR to read, flip, write back state of pin 
	// requires a RMW cycle (so not recommended)
	// alternative approach is to use bit set/reset register GPIOA_BSRR (atomic bit changes)
	while (1) {
		GPIOA->ODR ^= (1 << 5);
		delay(1000000);
	}

	return 0;
}
