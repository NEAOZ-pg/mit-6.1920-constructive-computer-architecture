char *s = "Success\n";
char *f = "Failure\n";

static volatile int input_data[8] = {0, 1, 2, 3, 4, 5, 6, 7};
static volatile int buffer_data[8] = {0, 0, 0, 0, 0, 0, 0, 0};

static volatile int flag = 0;

int program_thread0()
{
  for (int i = 0; i < 8; i++)
  {
    buffer_data[i] = input_data[i];
  }
  flag = 1;
  return 0;
}

int program_thread1()
{
  while (!flag)
  {
  }
  int sum = 0;
  for (int i = 0; i < 8; i++)
  {
    sum += input_data[i];
  }

  return !(sum == 28);
}

int main(int a)
{
  if (a == 0)
  {
    return program_thread0();
  }
  else
  {
    return program_thread1();
  }
}
