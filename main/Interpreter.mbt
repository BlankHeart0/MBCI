fn interpret(source:String)->Unit{
  //source code
  println(source)

  //Scan
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

  //Parse
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
      
      //Excute
      let excuter:Excuter={
        ast:ast,
        functable:FunctionTable::new(),
        vartable_stack:@vec.Vec::new(),
        is_returned:false,
        line:0,
        is_error:false
      }
      excuter.excute()

    }
    Err(_) => ()
  }
}

fn main {
  interpret(@test.expression)
  interpret(@test.scope)
  interpret(@test.add)
}
