enum ErrorType {
  E_Scanner
  E_Parser
}

fn error(e_type : ErrorType, line : Int, message : String) -> Unit {
  match e_type {
    E_Scanner  =>  print("Scan Error,")
    E_Parser  =>  print("Parse Error,")
  }
  print("Line " + line.to_string())
  println(": " + message)
}
