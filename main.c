#include <stdint.h>

#define LED		*((volatile unsigned long *)(0x40000000))

#define GPIO_DIR		*((volatile unsigned long *)(0x40008000))
#define GPIO_OUT		*((volatile unsigned long *)(0x40008004))
#define GPIO_IO			*((volatile unsigned long *)(0x40008008))
	
#define UART_FIFO		*((volatile unsigned long *)(0x40005000))
#define UART_STATUS	*((volatile unsigned long *)(0x40005004))
	
#define INT_ENABLE_REG	*((volatile unsigned long *)(0xE000E100))
#define INT_CLEAR_REG		*((volatile unsigned long *)(0xE000E180))
#define INT_SET_PEND		*((volatile unsigned long *)(0xE000E200))
#define INT_CLEAR_PEND	*((volatile unsigned long *)(0xE000E280))
#define INT_ACTIVE_BIT	*((volatile unsigned long *)(0xE000E300))
#define INT_PRIORITY		*((volatile unsigned long *)(0xE000E400))
#define INT_SOFT_TRIG		*((volatile unsigned long *)(0xE000EF00))

#define UP			8
#define DOWN		9
#define LEFT 		10
#define RIGHT 	11
#define CENTER	12

const unsigned char LD_DATA[13] = { 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x3E, 0x3F, 0x38, 0x77, 0x39 };
																	/* 1     2     3     4     5     6     7     8     U     D     L     R     C */
const unsigned char LD_POSITION[8] = { 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };

static int button_tmp = 100;
unsigned char button_data = 0xFF;

unsigned char uart_buf;
unsigned char gpio_uart_tmp = 0;

void light_shuma(unsigned char p, unsigned char data)
{
	  unsigned short led_tmp = (~LD_DATA[data]) & 0x00FF;
	  unsigned short position_tmp = (~LD_POSITION[p]) & 0x00FF;
	  LED = (led_tmp << 8) | position_tmp;
}

void delay()
{
	  int i, j;
	  for(i = 0; i < 100; i++)
	      for(j = 0; j < 100; j++);
}

int main(void)
{
	  unsigned long gpio_read;
	  unsigned long tmp;
	  int i = 0;
	
		LED = 0x00FF;
		
	  /* 配置GPIO的方向 */
		GPIO_DIR = 0xFFFF0000;
	  tmp = 0x00000000;
	
	  GPIO_OUT = 0x55550000;	
	
	  /* 中断设置 */
	  INT_ENABLE_REG = 0x0000003F;
	  GPIO_OUT = 0xFFFF0000;
	  
	  UART_FIFO = 'K';
	  UART_FIFO = 'a';
//	  uart_buf = UART_STATUS;
//		while((uart_buf & 0x01)	== 0);
	  
    while(1)
		{
			  gpio_read = GPIO_IO & 0x0000FFFF;
			  tmp = gpio_read << 16;
				
				if(gpio_uart_tmp == 0)
			      GPIO_OUT = tmp | gpio_read;
				else 
					  GPIO_OUT = 0xFFFF0000 | gpio_read;
				
/*			  i++;
			  if(i == 100)
				{
					  tmp++;
					  if(tmp == 0xFFFF)
				        tmp = 0x0;
						GPIO_OUT = tmp << 16;
						i = 0;
				}
*/		
			  if(button_data == 0xFF)
				{
						light_shuma(1, 1);
						delay();
						light_shuma(2, 2);
						delay();
						light_shuma(3, 3);
						delay();
						light_shuma(4, 4);
						delay();
						light_shuma(5, 5);
						delay();
						light_shuma(6, 6);
						delay();
						light_shuma(7, 7);
						delay();
						light_shuma(8, 8);
						delay();
				}
				else 
				{
					  light_shuma(1, button_data);
						delay();
						light_shuma(2, button_data);
						delay();
						light_shuma(3, button_data);
						delay();
						light_shuma(4, button_data);
						delay();
						light_shuma(5, button_data);
						delay();
						light_shuma(6, button_data);
						delay();
						light_shuma(7, button_data);
						delay();
						light_shuma(8, button_data);
						delay();
				}
    }
}

/* button up interrupt handler */
void external_int0_handler()
{
	  if(button_tmp == 100)		// 如果之前没有按下，则标记为0
		{
			  button_tmp = 0;
			  button_data = UP;
		}
		else if(button_tmp == 0)		// 如果之前该按键按下，则恢复没有按下
		{
			  button_tmp = 100;
			  button_data = 0xFF;		// 表示不显示
		}
		else			// 如果之前按下的不是这个按键，则替换成这个按键
		{
			  button_tmp = 0;
			  button_data = UP;
		}
}

/* button down interrupt handler */
void external_int1_handler()
{
	  if(button_tmp == 100)
		{
			  button_tmp = 1;
			  button_data = DOWN;
		}
		else if(button_tmp == 1)
		{
			  button_tmp = 100;
			  button_data = 0xFF;
		}
		else
		{
			  button_tmp = 1;
			  button_data = DOWN;
		}
}

/* button left interrupt handler */
void external_int2_handler()
{
	  if(button_tmp == 100)
		{
			  button_tmp = 2;
			  button_data = LEFT;
		}
		else if(button_tmp == 2)
		{
			  button_tmp = 100;
			  button_data = 0xFF;
		}
		else
		{
			  button_tmp = 2;
			  button_data = LEFT;
		}
}

/* button right interrupt handler */
void external_int3_handler()
{
	  if(button_tmp == 100)
		{
			  button_tmp = 3;
			  button_data = RIGHT;
		}
		else if(button_tmp == 3)
		{
			  button_tmp = 100;
			  button_data = 0xFF;
		}
		else
		{
			  button_tmp = 3;
			  button_data = RIGHT;
		}
}

/* button center interrupt handler */
void external_int4_handler()
{
	  if(button_tmp == 100)
		{
			  button_tmp = 4;
			  button_data = CENTER;
		}
		else if(button_tmp == 4)
		{
			  button_tmp = 100;
			  button_data = 0xFF;
		}
		else
		{
			  button_tmp = 4;
			  button_data = CENTER;
		}
}

/* uart interrupt handler */
void external_int5_handler()
{ 
//	gpio_uart_tmp = (gpio_uart_tmp == 0) ? 1 : 0;
	  uart_buf = UART_FIFO;
		UART_FIFO = uart_buf;
		GPIO_OUT = 0xFF000000;
	
	  GPIO_OUT = 0x00FF0000;
	  
/*	  uart_buf = UART_FIFO;
	  UART_FIFO = uart_buf;
	
	  uart_buf = UART_STATUS;
		while((uart_buf & 0x01)	== 0);
*/	
}