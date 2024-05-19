let error_number:Int = -1073741829

enum ErrorType {
  E_Scanner
  E_Parser
  E_Symbol
  E_Others
}

fn error(e_type : ErrorType, line : Int, message : String) -> Unit {
  match e_type {
    E_Scanner  =>  print("Scan Error,")
    E_Parser  =>  print("Parse Error,")
    E_Symbol => print("Symbol Error,")
    E_Others => print("Other Error,")
  }
  print("Line " + line.to_string())
  println(": " + message)
}

fn Scanner::scanError(self:Scanner,message:String)->Unit{
  if not(self.is_error){
    self.is_error=true
    error(E_Scanner,self.line,message)
  }
}

fn Parser::parseError(self:Parser,message:String)->Unit{
  if not(self.is_error){
    self.is_error=true
    error(E_Parser,self.line,message)
  }
}

fn Excuter::symbolError(self:Excuter,message:String)->Unit{
  if not(self.is_error){
    self.is_error=true
    error(E_Symbol,self.line,message)
  }
}

fn Excuter::otherError(self:Excuter,message:String)->Unit{
  if not(self.is_error){
    self.is_error=true
    error(E_Others,self.line,message)
  }
}