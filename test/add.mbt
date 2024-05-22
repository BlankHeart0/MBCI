pub let add=
#|int add(int a,int b){
#|  return a+b;
#|}
#|
#|int x=-10;
#|
#|void addx_one(){
#|  x=x+1;
#|}
#|
#|int main()
#|{
#|  print add(add(1,2),add(3,4));
#|  
#|  int i=0;
#|  
#|  while(i<3){
#|    addx_one();
#|    print x;  
#|    i=i+1;
#|  }  
#|
#|  return 0;
#|}