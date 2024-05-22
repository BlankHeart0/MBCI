pub let scope=
#|int a=0;
#|
#|int main() {
#|  printf("a0 = %d\n",a);      //0
#|
#|  int a=1;
#|  printf("a1 = %d\n",a);      //1
#| 
#|  {
#|    int a=2;
#|    printf("a2 = %d\n",a);    //2
#|    {
#|      a=a+1; 
#|      printf("a2 = %d\n",a);  //3
#|
#|      int a=999;
#|      printf("a3 = %d\n",a);  //999
#|    }
#|  }
#|
#|  printf("a1 = %d\n",a);      //1
#|}