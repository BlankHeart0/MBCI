pub let add=
#|int add(int a,int b){
#|  return a+b;
#|}
#|
#|int x=-10;
#|
#|void x_increment(){
#|  x=x+1;
#|}
#|
#|int main()
#|{
#|  printf("1+2+3+4= %d\n",add(add(1,2),add(3,4)));
#|  
#|  int i=0;
#|  
#|  while(i<3){
#|    x_increment();
#|    printf("x = %d\n",x);
#|    i=i+1;
#|  }  
#|
#|  return 0;
#|}