pub let scope=
#|int main() {
#|  int a=0;
#|  int b;
#|  print a;
#|  {
#|    int a=-100;
#|    print a;
#|    print b;
#|    {
#|      a=a+1;
#|      print a;
#|      int a=999;
#|      print a;
#|    }
#|  }
#|  print a;
#|}