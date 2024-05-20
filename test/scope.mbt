pub let scope=
#|int main() {
#|  int a=0;
#|  int b;
#|  print a; //0
#|  {
#|    int a=-100;
#|    print a; //-100
#|    print b; //0
#|    {
#|      a=a+1; 
#|      print a; //-99
#|      int a=999;
#|      print a; //999
#|    }
#|  }
#|  print a; //0
#|}