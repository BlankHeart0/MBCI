fn logo()->Unit{
  println("")
  println("MM    MM   BBBB     CCC    IIII")
  println("M M  M M   B  BB   CC  C    II")
  println("M  MM  M   BBB     C        II")
  println("M      M   B  BB   CC  C    II")
  println("MM    MM   BBBB     CCC    IIII")
  println("")
}

fn interpret(program_name:String,source:String)->Unit{
  println("-------------- Program Name ------------->")
  println(program_name)
  println("")

  //Source code
  println("-------------- Source Code -------------->")
  println(source)
  println("")

  //Scan
  println("----------------- Token ----------------->")
  let scanner:Scanner = {
    source:source, 
    start:0, 
    current:0, 
    line:1,
    is_error:false
  }
  let tokens=scanner.scan()
  if scanner.is_error {return}
  tokensPrint(tokens) // print tokens
  println("")

  //Parse
  println("---------- AbstractSyntaxTree ---------->")
  let parser:Parser = {
    tokens:tokens,
    current:0,
    line:1,
    is_void:false,
    is_error:false
  }
  let ast=parser.parseTranslationUnit()
  if parser.is_error {return}
  

  match ast {
    Ok(ast) => {
      astPrint(ast,0) // print ast
      println("")

      //Excute
      println("--------------- Excuting ---------------->")
      let excuter:Excuter={
        ast:ast,
        functable:FunctionTable::new(),
        global_vartable:@hashmap.HashMap::new(),
        vartable_stack:@vec.Vec::new(),
        return_value:error_number,
        is_returned:false,
        line:0,
        is_error:false
      }
     excuter.excute()

      if excuter.is_error{
        println("---------------- Error! ----------------->")
      }
      else {println("----------------- Done ------------------>")}
      println("")
    }
    Err(_) => ()
  }
}

fn main {
  logo()

  //interpret("hello",@test.hello)
  //interpret("add",@test.add)
  //interpret("scope",@test.scope)
  //interpret("prime",@test.prime)
  interpret("fibonacci",@test.fib)
}
