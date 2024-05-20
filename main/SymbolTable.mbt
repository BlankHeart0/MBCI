// Variable
enum DataType {
  D_Int
}

struct Variable {
  data_type:DataType
  name:String
  mut value:Int
}

struct VariableTable {
  mut table:@vec.Vec[@hashmap.HashMap[String,Variable]]
}

fn VariableTable::new()->VariableTable{
  {table:@vec.Vec::new()}
}

fn VariableTable::enterScope(self:VariableTable)->Unit{
  self.table.push(@hashmap.HashMap::new())
}

fn VariableTable::leaveScope(self:VariableTable)->Unit{
  let x=self.table.pop_exn()
}

fn VariableTable::add(self:VariableTable,variable:Variable)->Bool{
  match self.table[self.table.length()-1].get(variable.name) {
    Some(_) => false
    None => {
      self.table[self.table.length()-1].set(variable.name,variable)
      true
    }
  }
}

fn VariableTable::get(self:VariableTable,name:String)->Result[Int,Unit]{
  for i=self.table.length()-1;i>=0;i=i-1{
    match self.table[i].get(name) {
      Some(variable) => return Ok(variable.value)
      None => ()
    }
  }
  Err(())
}

fn VariableTable::set(self:VariableTable,name:String,to_value:Int)->Bool{
  for i=self.table.length()-1;i>=0;i=i-1{
    match self.table[i].get(name) {
      Some(variable) => 
        {
          variable.value=to_value
          return true
        }
      None => () 
    }
  }
  false
}



// Function
enum ReturnType {
  R_Void
  R_Int
}

struct Parameter {
  data_type:DataType
  name:String
}

struct Function {
  ret_type:ReturnType
  name:String
  body:AST
  parameters:@vec.Vec[Parameter]
}

struct FunctionTable {
  mut table:@hashmap.HashMap[String,Function]
}

fn FunctionTable::new()->FunctionTable{
  {table:@hashmap.HashMap::new()}
}

fn FunctionTable::add(self:FunctionTable,function:Function)->Bool{
  match self.table.get(function.name){
    Some(_) => false
    None => {
      self.table.set(function.name,function)
      true
    }
  }
}

fn FunctionTable::get(self:FunctionTable,name:String)->Result[Function,Unit]{
  match self.table.get(name) {
    Some(function) => Ok(function)
    None => Err(())
  }
}