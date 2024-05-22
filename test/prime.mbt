pub let prime=
#|int is_prime(int x)
#|{
#|  if(x<=1)return 0;
#|  
#|  int i=2;
#|  while(i<x){
#|    if(x%i==0)return 0;
#|    i=i+1;
#|  }
#|
#|  return 1;
#|}
#|
#|int main()
#|{
#|  printf("All prime numbers up to 1000 are as follows :\n\n");
#|  
#|  int n=0;
#|  int i=1;
#|
#|  while(n<=1000){
#|    if(is_prime(n)){
#|      printf("Prime%d : %d\n",i,n);
#|      i=i+1;    
#|    }
#|    n=n+1;
#|  }
#|  
#|  printf("\nSum : %d\n",i-1);
#|
#|  return 0;
#|}