pub let fib = 
  #|/*
  #|  Fibonacci 
  #|  Sequence
  #|*/
  #|
  #|int fib(int n)
  #|{
  #|  if(n<=0)return 0;
  #|  else if(n==1||n==2)return 1;
  #|
  #|  return fib(n-1)+fib(n-2); //Recursive
  #|}
  #|
  #|int main()
  #|{
  #|  int i=0;
  #|  while(i<10)
  #|  {
  #|    print fib(i);
  #|    i=i+1;
  #|  }
  #|
  #|  return 0;
  #|}