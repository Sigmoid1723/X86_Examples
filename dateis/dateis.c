#include <stdio.h>
#include <time.h>

int main()
{
  time_t timeval;

  (void)time(&timeval);
  printf("The date and time are: %s",ctime(&timeval));
  
  return 0;
}
