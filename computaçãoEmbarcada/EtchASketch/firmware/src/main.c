/************************************************************************
* 5 semestre - Eng. da Computao - Insper
*
* 2021 - Exemplo com HC05 com RTOS
*
*/

#include <asf.h>
#include "conf_board.h"
#include <string.h>

/************************************************************************/
/* defines                                                              */
/************************************************************************/

// LED Placa
#define LED_PIO      PIOC
#define LED_PIO_ID   ID_PIOC
#define LED_IDX      8
#define LED_IDX_MASK (1 << LED_IDX)

// Botão da Placa
#define BUT_PIO PIOA
#define BUT_PIO_ID ID_PIOA
#define BUT_IDX 11
#define BUT_IDX_MASK (1 << BUT_IDX)

// Botão Red
#define BUT_RED_PIO PIOD
#define BUT_RED_PIO_ID ID_PIOD
#define BUT_RED_IDX 31
#define BUT_RED_IDX_MASK (1 << BUT_RED_IDX)

// Botão Blue
#define BUT_BLUE_PIO PIOC
#define BUT_BLUE_PIO_ID ID_PIOC
#define BUT_BLUE_IDX 19
#define BUT_BLUE_IDX_MASK (1 << BUT_BLUE_IDX)

// Botão Green
#define BUT_GREEN_PIO PIOA
#define BUT_GREEN_PIO_ID ID_PIOA
#define BUT_GREEN_IDX 4
#define BUT_GREEN_IDX_MASK (1 << BUT_GREEN_IDX)

// Botão Erase_All
#define BUT_ERASE_ALL_PIO PIOD
#define BUT_ERASE_ALL_PIO_ID ID_PIOD
#define BUT_ERASE_ALL_IDX 25
#define BUT_ERASE_ALL_IDX_MASK (1 << BUT_ERASE_ALL_IDX)

// Botão Exit
#define BUT_EXIT_PIO PIOA
#define BUT_EXIT_PIO_ID ID_PIOA
#define BUT_EXIT_IDX 3
#define BUT_EXIT_IDX_MASK (1 << BUT_EXIT_IDX)

// Botão Joy Up
#define BUT_JOY_UP_PIO PIOD
#define BUT_JOY_UP_PIO_ID ID_PIOD
#define BUT_JOY_UP_IDX 11
#define BUT_JOY_UP_IDX_MASK (1 << BUT_JOY_UP_IDX)

// Botão Joy Down
#define BUT_JOY_DOWN_PIO PIOD
#define BUT_JOY_DOWN_PIO_ID ID_PIOD
#define BUT_JOY_DOWN_IDX 12
#define BUT_JOY_DOWN_IDX_MASK (1 << BUT_JOY_DOWN_IDX)

// Botão Joy Left
#define BUT_JOY_LEFT_PIO PIOA
#define BUT_JOY_LEFT_PIO_ID ID_PIOA
#define BUT_JOY_LEFT_IDX 27
#define BUT_JOY_LEFT_IDX_MASK (1 << BUT_JOY_LEFT_IDX)

// Botão Joy Right
#define BUT_JOY_RIGHT_PIO PIOD
#define BUT_JOY_RIGHT_PIO_ID ID_PIOD
#define BUT_JOY_RIGHT_IDX 27
#define BUT_JOY_RIGHT_IDX_MASK (1 << BUT_JOY_RIGHT_IDX)

// Potenciômetro de Saturação
#define AFEC0_POT AFEC0
#define AFEC0_POT_ID ID_AFEC0
#define AFEC0_POT_CHANNEL 0 // Canal do pino PD30

// LED RED
#define LED_RED_PIO PIOD
#define LED_RED_PIO_ID ID_PIOD
#define LED_RED_IDX 24
#define LED_RED_IDX_MASK (1u << LED_RED_IDX)

// LED BLUE
#define LED_BLUE_PIO PIOA
#define LED_BLUE_PIO_ID ID_PIOA
#define LED_BLUE_IDX 24
#define LED_BLUE_IDX_MASK (1u << LED_BLUE_IDX)

// LED GREEN
#define LED_GREEN_PIO PIOD
#define LED_GREEN_PIO_ID ID_PIOD
#define LED_GREEN_IDX 22
#define LED_GREEN_IDX_MASK (1u << LED_GREEN_IDX)

// LED HANDSHAKE
#define LED_HANDSHAKE_PIO PIOB 
#define LED_HANDSHAKE_PIO_ID ID_PIOB
#define LED_HANDSHAKE_IDX 3
#define LED_HANDSHAKE_IDX_MASK (1u << LED_HANDSHAKE_IDX)

// Botão Handshake 
#define BUT_HANDSHAKE_PIO PIOD 
#define BUT_HANDSHAKE_PIO_ID ID_PIOD
#define BUT_HANDSHAKE_IDX 21
#define BUT_HANDSHAKE_IDX_MASK (1 << BUT_HANDSHAKE_IDX)

// usart (bluetooth ou serial)
// Descomente para enviar dados
// pela serial debug

// #define DEBUG_SERIAL

#ifdef DEBUG_SERIAL
#define USART_COM USART1
#define USART_COM_ID ID_USART1
#else
#define USART_COM USART0
#define USART_COM_ID ID_USART0
#endif

/************************************************************************/
/* RTOS                                                                 */
/************************************************************************/

#define TASK_BLUETOOTH_STACK_SIZE            (4096/sizeof(portSTACK_TYPE))
#define TASK_BLUETOOTH_STACK_PRIORITY        (tskIDLE_PRIORITY)

#define TASK_SATURATION_STACK_SIZE            (4096/sizeof(portSTACK_TYPE))
#define TASK_SATURATION_STACK_PRIORITY        (tskIDLE_PRIORITY)

#define TASK_LED_STACK_SIZE            (4096/sizeof(portSTACK_TYPE))
#define TASK_LED_STACK_PRIORITY        (tskIDLE_PRIORITY)

/************************************************************************/
/* Recursos RTOS                                                        */
/************************************************************************/

TimerHandle_t xTimer;

QueueHandle_t xQueueInstructions;

QueueHandle_t xQueueLeds;

typedef struct
{
	char head;
	uint id; // identificação da instrução
	uint value;
} instructionData;

typedef struct {
	char red;
	char blue;
	char green;
	char handshake;
} ledData;

/************************************************************************/
/* Protótipos de Funções Locais                                         */
/************************************************************************/

extern void vApplicationStackOverflowHook(xTaskHandle *pxTask,
signed char *pcTaskName);
extern void vApplicationIdleHook(void);
extern void vApplicationTickHook(void);
extern void vApplicationMallocFailedHook(void);
extern void xPortSysTickHandler(void);
static void config_AFEC_pot(Afec *afec, uint32_t afec_id, uint32_t afec_channel,
							afec_callback_t callback);

extern void vApplicationStackOverflowHook(xTaskHandle *pxTask,
signed char *pcTaskName) {
	printf("stack overflow %x %s\r\n", pxTask, (portCHAR *)pcTaskName);
	/* If the parameters have been corrupted then inspect pxCurrentTCB to
	* identify which task has overflowed its stack.
	*/
	for (;;) {
	}
}

extern void vApplicationIdleHook(void) {
	pmc_sleep(SAM_PM_SMODE_SLEEP_WFI);
}

extern void vApplicationTickHook(void) { }

extern void vApplicationMallocFailedHook(void) {
	/* Called if a call to pvPortMalloc() fails because there is insufficient
	free memory available in the FreeRTOS heap.  pvPortMalloc() is called
	internally by FreeRTOS API functions that create tasks, queues, software
	timers, and semaphores.  The size of the FreeRTOS heap is set by the
	configTOTAL_HEAP_SIZE configuration constant in FreeRTOSConfig.h. */

	/* Force an assert. */
	configASSERT( ( volatile void * ) NULL );
}

static void config_AFEC_pot(Afec *afec, uint32_t afec_id, uint32_t afec_channel,
							afec_callback_t callback)
{
	/*************************************
	 * Ativa e configura AFEC
	 ***********************************/
	/* Ativa AFEC - 0 */
	afec_enable(afec);

	/* struct de configuração do AFEC */
	struct afec_config afec_cfg;

	/* Carrega parâmetros padrão */
	afec_get_config_defaults(&afec_cfg);

	/* Configura AFEC */
	afec_init(afec, &afec_cfg);

	/* Configura trigger por software */
	afec_set_trigger(afec, AFEC_TRIG_SW);

	/*** Configuração específica do canal AFEC ***/
	struct afec_ch_config afec_ch_cfg;
	afec_ch_get_config_defaults(&afec_ch_cfg);
	afec_ch_cfg.gain = AFEC_GAINVALUE_0;
	afec_ch_set_config(afec, afec_channel, &afec_ch_cfg);

	/*
	* Calibração:
	* Because the internal ADC offset is 0x200, it should cancel it and shift
	down to 0.
	*/
	afec_channel_set_analog_offset(afec, afec_channel, 0x200);

	/*** Configura sensor de temperatura ***/
	struct afec_temp_sensor_config afec_temp_sensor_cfg;

	afec_temp_sensor_get_config_defaults(&afec_temp_sensor_cfg);
	afec_temp_sensor_set_config(afec, &afec_temp_sensor_cfg);

	/* Configura IRQ */
	afec_set_callback(afec, afec_channel, callback, 1);
	NVIC_SetPriority(afec_id, 4);
	NVIC_EnableIRQ(afec_id);
}

static void configure_console(void) {
	const usart_serial_options_t uart_serial_options = {
		.baudrate = CONF_UART_BAUDRATE,
		#if (defined CONF_UART_CHAR_LENGTH)
		.charlength = CONF_UART_CHAR_LENGTH,
		#endif
		.paritytype = CONF_UART_PARITY,
		#if (defined CONF_UART_STOP_BITS)
		.stopbits = CONF_UART_STOP_BITS,
		#endif
	};

	/* Configure console UART. */
	stdio_serial_init(CONF_UART, &uart_serial_options);

	/* Specify that stdout should not be buffered. */
	#if defined(__GNUC__)
	setbuf(stdout, NULL);
	#else
	/* Already the case in IAR's Normal DLIB default configuration: printf()
	* emits one character at a time.
	*/
	#endif
}

/************************************************************************/
/* Handlers / Callbacks                                                 */
/************************************************************************/

void but_handshake_callback(void) // id 0 - funciona
{
	// Envia evento para task
	instructionData data;
	data.head = 'H';
	data.id = 0;
	data.value = 1;

	ledData led;
	led.red = 0;
	led.blue = 0;
	led.green = 0;
	led.handshake = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
	xQueueSendFromISR(xQueueLeds, &led, &xHigherPriorityTaskWoken);

}

void but_placa_callback(void) //id 1 - funciona
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 1;

	if (!pio_get(BUT_PIO, PIO_INPUT, BUT_IDX_MASK))
		data.value = 0;
	else
		data.value = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_red_callback(void) //id 2
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 2;
	data.value = 1;

	ledData led;
	led.red = 1;
	led.blue = 0;
	led.green = 0;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
	xQueueSendFromISR(xQueueLeds, &led, &xHigherPriorityTaskWoken);
}

void but_blue_callback(void) //id 3
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 3;
	data.value = 1;

	ledData led;
	led.red = 0;
	led.blue = 1;
	led.green = 0;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
	xQueueSendFromISR(xQueueLeds, &led, &xHigherPriorityTaskWoken);
}

void but_green_callback(void) //id 4
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 4;
	data.value = 1;

	ledData led;
	led.red = 0;
	led.blue = 0;
	led.green = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
	xQueueSendFromISR(xQueueLeds, &led, &xHigherPriorityTaskWoken);
}

void but_erase_all_callback(void) //id 5
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 5;
	data.value = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_exit_callback(void) //id 6
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 6;
	data.value = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_joy_up_callback(void) //id 7
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 7;

	if (!pio_get(BUT_JOY_UP_PIO, PIO_INPUT, BUT_JOY_UP_IDX_MASK))
		data.value = 0;
	else
		data.value = 1;
	
	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_joy_down_callback(void) //id 8
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 8;

	if(!pio_get(BUT_JOY_DOWN_PIO, PIO_INPUT, BUT_JOY_DOWN_IDX_MASK))
		data.value = 0;
	else
		data.value = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_joy_left_callback(void) //id 9
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 9;

	if(!pio_get(BUT_JOY_LEFT_PIO, PIO_INPUT, BUT_JOY_LEFT_IDX_MASK))
		data.value = 0;
	else
		data.value = 1;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

void but_joy_right_callback(void) //id 10
{
	// Envia evento para task
	instructionData data;
	data.head = 'B';
	data.id = 10;

	if(!pio_get(BUT_JOY_RIGHT_PIO, PIO_INPUT, BUT_JOY_RIGHT_IDX_MASK))
		data.value = 0;
	else
		data.value = 1;
		
	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);
}

static void AFEC0_pot_callback(void) //id 11
{
	instructionData data;
	data.head = 'P';

	uint16_t valor = afec_channel_get_value(AFEC0_POT, AFEC0_POT_CHANNEL);

	char afec_baixo = valor;
	char afec_alto = valor >> 8;

	data.id = afec_alto;
	data.value = afec_baixo;

	BaseType_t xHigherPriorityTaskWoken = pdFALSE;
	xQueueSendFromISR(xQueueInstructions, &data, &xHigherPriorityTaskWoken);

}

/************************************************************************/
/* RTOS application funcs                                               */
/************************************************************************/

void vTimerCallback(TimerHandle_t xTimer)
{
	afec_channel_enable(AFEC0_POT, AFEC0_POT_CHANNEL);
	afec_start_software_conversion(AFEC0_POT);
}

void usart_put_string(Usart *usart, char str[]) {
	usart_serial_write_packet(usart, str, strlen(str));
}

int usart_get_string(Usart *usart, char buffer[], int bufferlen, uint timeout_ms) {
	uint timecounter = timeout_ms;
	uint32_t rx;
	uint32_t counter = 0;

	while( (timecounter > 0) && (counter < bufferlen - 1)) {
		if(usart_read(usart, &rx) == 0) {
			buffer[counter++] = rx;
		}
		else{
			timecounter--;
			vTaskDelay(1);
		}
	}
	buffer[counter] = 0x00;
	return counter;
}

void usart_send_command(Usart *usart, char buffer_rx[], int bufferlen,
char buffer_tx[], int timeout) {
	usart_put_string(usart, buffer_tx);
	usart_get_string(usart, buffer_rx, bufferlen, timeout);
}

void config_usart0(void) {
	sysclk_enable_peripheral_clock(ID_USART0);
	usart_serial_options_t config;
	config.baudrate = 9600;
	config.charlength = US_MR_CHRL_8_BIT;
	config.paritytype = US_MR_PAR_NO;
	config.stopbits = false;
	usart_serial_init(USART0, &config);
	usart_enable_tx(USART0);
	usart_enable_rx(USART0);
	
	// RX - PA21  TX - PB4
	pio_configure(PIOB, PIO_PERIPH_C, (1 << 0), PIO_DEFAULT);
	pio_configure(PIOB, PIO_PERIPH_C, (1 << 1), PIO_DEFAULT);
}

int hc05_init(void) {
	char buffer_rx[128];
	usart_send_command(USART_COM, buffer_rx, 1000, "AT", 100);
	vTaskDelay( 500 / portTICK_PERIOD_MS);
	usart_send_command(USART_COM, buffer_rx, 1000, "AT", 100);
	vTaskDelay( 500 / portTICK_PERIOD_MS);
	usart_send_command(USART_COM, buffer_rx, 1000, "AT+NAMEdonca", 100);
	vTaskDelay( 500 / portTICK_PERIOD_MS);
	usart_send_command(USART_COM, buffer_rx, 1000, "AT", 100);
	vTaskDelay( 500 / portTICK_PERIOD_MS);
	usart_send_command(USART_COM, buffer_rx, 1000, "AT+PIN1234", 100);
}

void init(void)
{
	sysclk_init();

	// Desativa WatchDog Timer
	WDT->WDT_MR = WDT_MR_WDDIS;

	// Inicializando Botão da Placa
	pmc_enable_periph_clk(BUT_PIO_ID);
	pio_set_input(BUT_PIO, BUT_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_PIO, BUT_IDX_MASK, 1);
	pio_configure(BUT_PIO, PIO_INPUT, BUT_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_PIO, BUT_IDX_MASK, 60);

	// Inicializando Botão Red

	pmc_enable_periph_clk(BUT_RED_PIO_ID);
	pio_set_input(BUT_RED_PIO, BUT_RED_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_RED_PIO, BUT_RED_IDX_MASK, 1);
	pio_configure(BUT_RED_PIO, PIO_INPUT, BUT_RED_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_RED_PIO, BUT_RED_IDX_MASK, 60);

	// Inicializando Botão Blue

	pmc_enable_periph_clk(BUT_BLUE_PIO_ID);
	pio_set_input(BUT_BLUE_PIO, BUT_BLUE_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_BLUE_PIO, BUT_BLUE_IDX_MASK, 1);
	pio_configure(BUT_BLUE_PIO, PIO_INPUT, BUT_BLUE_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_BLUE_PIO, BUT_BLUE_IDX_MASK, 60);

	// Inicializando Botão Green

	pmc_enable_periph_clk(BUT_GREEN_PIO_ID);
	pio_set_input(BUT_GREEN_PIO, BUT_GREEN_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_GREEN_PIO, BUT_GREEN_IDX_MASK, 1);
	pio_configure(BUT_GREEN_PIO, PIO_INPUT, BUT_GREEN_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_GREEN_PIO, BUT_GREEN_IDX_MASK, 60);

	// Inicializando Botão Erase_All

	pmc_enable_periph_clk(BUT_ERASE_ALL_PIO_ID);
	pio_set_input(BUT_ERASE_ALL_PIO, BUT_ERASE_ALL_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_ERASE_ALL_PIO, BUT_ERASE_ALL_IDX_MASK, 1);
	pio_configure(BUT_ERASE_ALL_PIO, PIO_INPUT, BUT_ERASE_ALL_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_ERASE_ALL_PIO, BUT_ERASE_ALL_IDX_MASK, 60);

	// Inicializando Botão Exit

	pmc_enable_periph_clk(BUT_EXIT_PIO_ID);
	pio_set_input(BUT_EXIT_PIO, BUT_EXIT_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_EXIT_PIO, BUT_EXIT_IDX_MASK, 1);
	pio_configure(BUT_EXIT_PIO, PIO_INPUT, BUT_EXIT_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_EXIT_PIO, BUT_EXIT_IDX_MASK, 60);

	// Inicializando Botão Joy Up

	pmc_enable_periph_clk(BUT_JOY_UP_PIO_ID);
	pio_set_input(BUT_JOY_UP_PIO, BUT_JOY_UP_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_JOY_UP_PIO, BUT_JOY_UP_IDX_MASK, 1);
	pio_configure(BUT_JOY_UP_PIO, PIO_INPUT, BUT_JOY_UP_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_JOY_UP_PIO, BUT_JOY_UP_IDX_MASK, 60);

	// Inicializando Botão Joy Down

	pmc_enable_periph_clk(BUT_JOY_DOWN_PIO_ID);
	pio_set_input(BUT_JOY_DOWN_PIO, BUT_JOY_DOWN_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_JOY_DOWN_PIO, BUT_JOY_DOWN_IDX_MASK, 1);
	pio_configure(BUT_JOY_DOWN_PIO, PIO_INPUT, BUT_JOY_DOWN_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_JOY_DOWN_PIO, BUT_JOY_DOWN_IDX_MASK, 60);

	// Inicializando Botão Joy Left

	pmc_enable_periph_clk(BUT_JOY_LEFT_PIO_ID);
	pio_set_input(BUT_JOY_LEFT_PIO, BUT_JOY_LEFT_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_JOY_LEFT_PIO, BUT_JOY_LEFT_IDX_MASK, 1);
	pio_configure(BUT_JOY_LEFT_PIO, PIO_INPUT, BUT_JOY_LEFT_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_JOY_LEFT_PIO, BUT_JOY_LEFT_IDX_MASK, 60);

	// Inicializando Botão Joy Right

	pmc_enable_periph_clk(BUT_JOY_RIGHT_PIO_ID);
	pio_set_input(BUT_JOY_RIGHT_PIO, BUT_JOY_RIGHT_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_JOY_RIGHT_PIO, BUT_JOY_RIGHT_IDX_MASK, 1);
	pio_configure(BUT_JOY_RIGHT_PIO, PIO_INPUT, BUT_JOY_RIGHT_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_JOY_RIGHT_PIO, BUT_JOY_RIGHT_IDX_MASK, 60);

	// Inicializando Botão Handshake

	pmc_enable_periph_clk(BUT_HANDSHAKE_PIO_ID);
	pio_set_input(BUT_HANDSHAKE_PIO, BUT_HANDSHAKE_IDX_MASK, PIO_DEFAULT);
	pio_pull_up(BUT_HANDSHAKE_PIO, BUT_HANDSHAKE_IDX_MASK, 1);
	pio_configure(BUT_HANDSHAKE_PIO, PIO_INPUT, BUT_HANDSHAKE_IDX_MASK, PIO_PULLUP | PIO_DEBOUNCE);
	pio_set_debounce_filter(BUT_HANDSHAKE_PIO, BUT_HANDSHAKE_IDX_MASK, 60);

	// Inicializando LED Placa

	pmc_enable_periph_clk(LED_PIO_ID);
	pio_set_output(LED_PIO, LED_IDX_MASK, 0, 0, 0);

	// Inicializando LED Red

	pmc_enable_periph_clk(LED_RED_PIO_ID);
	pio_set_output(LED_RED_PIO, LED_RED_IDX_MASK, 0, 0, 0);

	// Inicializando LED Blue

	pmc_enable_periph_clk(LED_BLUE_PIO_ID);
	pio_set_output(LED_BLUE_PIO, LED_BLUE_IDX_MASK, 0, 0, 0);

	// Inicializando LED Green

	pmc_enable_periph_clk(LED_GREEN_PIO_ID);
	pio_set_output(LED_GREEN_PIO, LED_GREEN_IDX_MASK, 0, 0, 0);

	// Inicializando LED Handshake

	pmc_enable_periph_clk(LED_HANDSHAKE_PIO_ID);
	pio_set_output(LED_HANDSHAKE_PIO, LED_HANDSHAKE_IDX_MASK, 0, 0, 0);

	pio_handler_set(BUT_PIO, BUT_PIO_ID, BUT_IDX_MASK, PIO_IT_EDGE, but_placa_callback);
	pio_handler_set(BUT_RED_PIO, BUT_RED_PIO_ID, BUT_RED_IDX_MASK, PIO_IT_FALL_EDGE, but_red_callback);
	pio_handler_set(BUT_BLUE_PIO, BUT_BLUE_PIO_ID, BUT_BLUE_IDX_MASK, PIO_IT_FALL_EDGE, but_blue_callback);
	pio_handler_set(BUT_GREEN_PIO, BUT_GREEN_PIO_ID, BUT_GREEN_IDX_MASK, PIO_IT_FALL_EDGE, but_green_callback);
	pio_handler_set(BUT_ERASE_ALL_PIO, BUT_ERASE_ALL_PIO_ID, BUT_ERASE_ALL_IDX_MASK, PIO_IT_FALL_EDGE, but_erase_all_callback);
	pio_handler_set(BUT_EXIT_PIO, BUT_EXIT_PIO_ID, BUT_EXIT_IDX_MASK, PIO_IT_FALL_EDGE, but_exit_callback);
	pio_handler_set(BUT_JOY_UP_PIO, BUT_JOY_UP_PIO_ID, BUT_JOY_UP_IDX_MASK, PIO_IT_EDGE, but_joy_up_callback);
	pio_handler_set(BUT_JOY_DOWN_PIO, BUT_JOY_DOWN_PIO_ID, BUT_JOY_DOWN_IDX_MASK, PIO_IT_EDGE, but_joy_down_callback);
	pio_handler_set(BUT_JOY_LEFT_PIO, BUT_JOY_LEFT_PIO_ID, BUT_JOY_LEFT_IDX_MASK, PIO_IT_EDGE, but_joy_left_callback);
	pio_handler_set(BUT_JOY_RIGHT_PIO, BUT_JOY_RIGHT_PIO_ID, BUT_JOY_RIGHT_IDX_MASK, PIO_IT_EDGE, but_joy_right_callback);
	pio_handler_set(BUT_HANDSHAKE_PIO, BUT_HANDSHAKE_PIO_ID, BUT_HANDSHAKE_IDX_MASK, PIO_IT_FALL_EDGE, but_handshake_callback);

	pio_enable_interrupt(BUT_PIO, BUT_IDX_MASK);
	pio_get_interrupt_status(BUT_PIO);

	pio_enable_interrupt(BUT_RED_PIO, BUT_RED_IDX_MASK);
	pio_get_interrupt_status(BUT_RED_PIO);

	pio_enable_interrupt(BUT_BLUE_PIO, BUT_BLUE_IDX_MASK);
	pio_get_interrupt_status(BUT_BLUE_PIO);

	pio_enable_interrupt(BUT_GREEN_PIO, BUT_GREEN_IDX_MASK);
	pio_get_interrupt_status(BUT_GREEN_PIO);

	pio_enable_interrupt(BUT_ERASE_ALL_PIO, BUT_ERASE_ALL_IDX_MASK);
	pio_get_interrupt_status(BUT_ERASE_ALL_PIO);

	pio_enable_interrupt(BUT_EXIT_PIO, BUT_EXIT_IDX_MASK);
	pio_get_interrupt_status(BUT_EXIT_PIO);

	pio_enable_interrupt(BUT_JOY_UP_PIO, BUT_JOY_UP_IDX_MASK);
	pio_get_interrupt_status(BUT_JOY_UP_PIO);

	pio_enable_interrupt(BUT_JOY_DOWN_PIO, BUT_JOY_DOWN_IDX_MASK);
	pio_get_interrupt_status(BUT_JOY_DOWN_PIO);

	pio_enable_interrupt(BUT_JOY_LEFT_PIO, BUT_JOY_LEFT_IDX_MASK);
	pio_get_interrupt_status(BUT_JOY_LEFT_PIO);

	pio_enable_interrupt(BUT_JOY_RIGHT_PIO, BUT_JOY_RIGHT_IDX_MASK);
	pio_get_interrupt_status(BUT_JOY_RIGHT_PIO);

	pio_enable_interrupt(BUT_HANDSHAKE_PIO, BUT_HANDSHAKE_IDX_MASK);
	pio_get_interrupt_status(BUT_HANDSHAKE_PIO);

	NVIC_EnableIRQ(BUT_PIO_ID);
	NVIC_SetPriority(BUT_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_RED_PIO_ID);
	NVIC_SetPriority(BUT_RED_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_BLUE_PIO_ID);
	NVIC_SetPriority(BUT_BLUE_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_GREEN_PIO_ID);
	NVIC_SetPriority(BUT_GREEN_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_ERASE_ALL_PIO_ID);
	NVIC_SetPriority(BUT_ERASE_ALL_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_EXIT_PIO_ID);
	NVIC_SetPriority(BUT_EXIT_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_JOY_UP_PIO_ID);
	NVIC_SetPriority(BUT_JOY_UP_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_JOY_DOWN_PIO_ID);
	NVIC_SetPriority(BUT_JOY_DOWN_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_JOY_LEFT_PIO_ID);
	NVIC_SetPriority(BUT_JOY_LEFT_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_JOY_RIGHT_PIO_ID);
	NVIC_SetPriority(BUT_JOY_RIGHT_PIO_ID, 4); // Prioridade 4

	NVIC_EnableIRQ(BUT_HANDSHAKE_PIO_ID);
	NVIC_SetPriority(BUT_HANDSHAKE_PIO_ID, 4); // Prioridade 4
}

/************************************************************************/
/* TASKS                                                                */
/************************************************************************/

void task_bluetooth(void) {
	printf("Task Bluetooth started \n");
	
	printf("Inicializando HC05 \n");
	config_usart0();
	hc05_init();
	init();

	char eof = 'X';

	int i = 0;
	int pot;
	int pot_anterior = 0;

	instructionData data;

	while (1)
	{
		if (xQueueReceive(xQueueInstructions, &data, 1))
		{
			if ((data.head == 'B') || (data.head == 'H'))
			{
				while (!usart_is_tx_ready(USART_COM))
				{
					vTaskDelay(10 / portTICK_PERIOD_MS);
				}
				usart_write(USART_COM, data.head);

				while (!usart_is_tx_ready(USART_COM))
				{
					vTaskDelay(10 / portTICK_PERIOD_MS);
				}
				usart_write(USART_COM, data.id);

				while (!usart_is_tx_ready(USART_COM))
				{
					vTaskDelay(10 / portTICK_PERIOD_MS);
				}
				usart_write(USART_COM, data.value);

				while (!usart_is_tx_ready(USART_COM))
				{
					vTaskDelay(10 / portTICK_PERIOD_MS);
				}
				usart_write(USART_COM, eof);
				
				if (data.head == 'H')
				{
					xQueueReset(xQueueInstructions);
				}
			}
			else if (data.head == 'P')
			{	
				if (i == 0) // Primeira vez que recebeu o valor do potenciometro pula o envio pois não é necessário
				{
					pot = (data.id << 8) | data.value; // Combina id e value
					i++;
				}
				else
				{
					pot = (data.id << 8) | data.value; // Combina id e value

					if (abs(pot - pot_anterior) > 15)
					{
						while (!usart_is_tx_ready(USART_COM))
						{
							vTaskDelay(10 / portTICK_PERIOD_MS);
						}
						usart_write(USART_COM, data.head);

						while (!usart_is_tx_ready(USART_COM))
						{
							vTaskDelay(10 / portTICK_PERIOD_MS);
						}
						usart_write(USART_COM, data.id);

						while (!usart_is_tx_ready(USART_COM))
						{
							vTaskDelay(10 / portTICK_PERIOD_MS);
						}
						usart_write(USART_COM, data.value);

						while (!usart_is_tx_ready(USART_COM))
						{
							vTaskDelay(10 / portTICK_PERIOD_MS);
						}
						usart_write(USART_COM, eof);

					}
				}
				pot_anterior = pot; // Atualize o valor anterior
			}
			else
			{
				printf("Erro: head invalido\n");
			}
			// dorme por 500 ms
			vTaskDelay(10 / portTICK_PERIOD_MS);

			uint32_t received_byte;
			usart_read(USART_COM, &received_byte);
			vTaskDelay(10 / portTICK_PERIOD_MS);
		}
	}
}

void task_saturation(void) {

	xTimer = xTimerCreate("Timer", 100, pdTRUE, (void *)0, vTimerCallback);
	xTimerStart(xTimer, 0);

	config_AFEC_pot(AFEC0_POT, AFEC0_POT_ID, AFEC0_POT_CHANNEL, AFEC0_pot_callback);
	while (1)
	{
		vTaskDelay(portMAX_DELAY);
	}
}

void task_led(void) {
	ledData data;
	while (1)
	{
		if (xQueueReceive(xQueueLeds, &data, (TickType_t)0))
		{	  
			if (data.handshake){
				pio_set(LED_HANDSHAKE_PIO, LED_HANDSHAKE_IDX_MASK);
			}

			if (data.red)
			{
				pio_set(LED_RED_PIO, LED_RED_IDX_MASK);
			}
			else
			{
				pio_clear(LED_RED_PIO, LED_RED_IDX_MASK);
			}
			if (data.blue)
			{
				pio_set(LED_BLUE_PIO, LED_BLUE_IDX_MASK);
			}
			else
			{
				pio_clear(LED_BLUE_PIO, LED_BLUE_IDX_MASK);
			}

			if (data.green)
			{
				pio_set(LED_GREEN_PIO, LED_GREEN_IDX_MASK);
			}
			else
			{
				pio_clear(LED_GREEN_PIO, LED_GREEN_IDX_MASK);
			}
		}
	}
}
/************************************************************************/
/* main                                                                 */
/************************************************************************/

int main(void) {

	xQueueInstructions = xQueueCreate(100, sizeof(instructionData));
	if (xQueueInstructions == NULL)
		printf("Falha ao criar a fila xQueueSaturationLevel\n");

	xQueueLeds = xQueueCreate(100, sizeof(ledData));
	if (xQueueLeds == NULL)
		printf("Falha ao criar a fila xQueueLeds\n");


	/* Initialize the SAM system */
	sysclk_init();
	board_init();

	configure_console();
		
	/* Create task to make led blink */
	xTaskCreate(task_bluetooth, "BLT", TASK_BLUETOOTH_STACK_SIZE, NULL,	TASK_BLUETOOTH_STACK_PRIORITY, NULL);

	xTaskCreate(task_saturation, "SAT", TASK_SATURATION_STACK_SIZE, NULL, TASK_SATURATION_STACK_PRIORITY, NULL);

	xTaskCreate(task_led, "LED", TASK_LED_STACK_SIZE, NULL, TASK_LED_STACK_PRIORITY, NULL);

	/* Start the scheduler. */
	vTaskStartScheduler();

	while(1){}

	/* Will only get here if there was insufficient memory to create the idle task. */
	return 0;
}
