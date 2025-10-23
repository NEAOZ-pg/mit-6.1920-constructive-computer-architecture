// Dangerous, we should add volatile
volatile int* PUT_ADDR = (int *)0xF000fff0;
volatile int* GET_ADDR = (int *)0xF000fff4;
volatile int* FINISH_ADDR = (int *)0xF000fff8;

int getchar() {
  return *GET_ADDR;
}

int putchar(int c) {
  *PUT_ADDR = c;
  return c;
}

int exit(int c) {
  *FINISH_ADDR = c;
  return c;
}
