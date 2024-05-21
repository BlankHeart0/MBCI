fn interpret(program_name:String,source:String)->Unit{
  println("Program : "+program_name)

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
        vartable_stack:@vec.Vec::new(),
        return_value:error_number,
        is_returned:false,
        line:0,
        is_error:false
      }
      excuter.excute()

      println("----------------- Done ------------------>")
      println("")
    }
    Err(_) => ()
  }
}

fn main {
  interpret("expression",@test.expression)
  interpret("scope",@test.scope)
  interpret("add",@test.add)
}
