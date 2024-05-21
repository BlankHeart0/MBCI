struct Excuter {
  ast:AST
  functable:FunctionTable
  vartable_stack:@vec.Vec[VariableTable]
  mut is_returned:Bool
  mut return_value:Int
  mut line:Int
  mut is_error:Bool
}



fn Excuter::excute(self:Excuter)->Unit{
  self.loadTranslationUnit()

  self.line=0
  if not(self.is_error){
    match self.functable.get("main"){
      Ok(main) => self.excuteFunction(main,@vec.Vec::new())
      Err(_) => self.otherError("Can not find 'main' function") 
    }
  }
}

fn Excuter::excuteFunction(self:Excuter,function:Function,arguments:@vec.Vec[Int])->Unit{
  whoAmI("excuteFunction")

  self.vartable_stack.push(VariableTable::new())
  self.vartable_stack[self.vartable_stack.length()-1].enterScope()

  self.line=function.line
  for i=0;i<arguments.length();i=i+1{
    let new_variable:Variable={
      data_type:function.parameters[i].data_type,
      name:function.parameters[i].name,
      value:arguments[i]
    }

    if not(self.vartable_stack[self.vartable_stack.length()-1].add(new_variable)){
      self.symbolError("The parameter: "+new_variable.name+" is redefined")
    }
  }

  self.excuteCompoundStatement(function.body,true)

  let x=self.vartable_stack.pop_exn()
}



// Translation Unit
fn Excuter::loadTranslationUnit(self:Excuter)->Unit{
  whoAmI("loadTranslationUnit")

  match self.ast {
    TranslationUnitAST(function_definitions) => 
      function_definitions.iter(
        fn(function_definition){
          self.loadFunctionDefinition(function_definition)
        }
      )
    
    _=> ()
  }
}

// Definition
fn Excuter::loadFunctionDefinition(self:Excuter,function_definition:AST)->Unit{
  whoAmI("loadFunctionDefinition")
  
  match function_definition {
    FunctionDefinitionAST(ret_type,function_name,parameters,compound_statement) => {
      self.line=function_name.line

      let new_function:Function={
        ret_type:match ret_type.t_type {VOID=>R_Void;INT=>R_Int},
        name:function_name.lexeme,
        body:compound_statement,
        parameters:@vec.Vec::new(),
        line:function_name.line
      }
      parameters.iter(
        fn(parameter){
          let new_parameter=self.loadParameter(parameter)
          new_function.parameters.push(new_parameter)
          }
        )
      
      if not(self.functable.add(new_function)){
        self.symbolError("The function: "+function_name.lexeme+" is redefined")
      }
    }
    _ => ()
  }
}

fn Excuter::loadParameter(self:Excuter,parameter:AST)->Parameter{
  whoAmI("loadParameter")

  match parameter{
    ParameterAST(data_type,parameter_name) => {
      let new_parameter:Parameter={
        data_type:match data_type.t_type{INT => D_Int},
        name:parameter_name.lexeme
      }
      new_parameter
    }
  }
}

fn Excuter::excuteLocalVariableDefinition(self:Excuter,localvar_definition:AST)->Unit{
  whoAmI("excuteLocalVariableDefinition")

  match localvar_definition{
    LocalVariableDefinitionAST(data_type,variable_name,expression_option) => {
      self.line=variable_name.line

      let initial_value=match expression_option{
        Some(expression) => self.excuteExpression(expression)
        None => 0
      }
      
      let new_variable:Variable={
        data_type:match data_type.t_type {INT=>D_Int},
        name:variable_name.lexeme,
        value:initial_value
      }

      if not(self.vartable_stack[self.vartable_stack.length()-1].add(new_variable)){
        self.symbolError("The variable: "+variable_name.lexeme+" is redefined")
      }
    }
    _ => ()
  }
}



// Statement
fn Excuter::excuteStatement(self:Excuter,statement:AST)->Unit{
  whoAmI("excuteStatement")
  if self.is_returned||self.is_error {return}

  match statement {
    StatementAST(x_statement) => 
      match x_statement {
        LocalVariableDefinitionAST(_) => self.excuteLocalVariableDefinition(x_statement)
        CompoundStatementAST(_) => self.excuteCompoundStatement(x_statement,false)
        AssignStatementAST(_) => self.excuteAssignStatement(x_statement)
        ReturnStatementAST(_) => self.excuteRetuerStatement(x_statement)
        PrintStatementAST(_) => self.excutePrintStatement(x_statement)
        ExpressionStatementAST(_) => self.excuteExpressionStatement(x_statement)
        _ => ()
      }
    _ => ()
  }
}

fn Excuter::excuteCompoundStatement(self:Excuter,compound_statement:AST,is_funcbody:Bool)->Unit{
  whoAmI("excuteCompoundStatement")

  if not(is_funcbody){
    self.vartable_stack[self.vartable_stack.length()-1].enterScope()
  }

  match compound_statement {
    CompoundStatementAST(statements) => 
      statements.iter(
        fn(statement){
          self.excuteStatement(statement)
        }
      )
    _=>()
  }

  self.vartable_stack[self.vartable_stack.length()-1].leaveScope()
}

fn Excuter::excuteAssignStatement(self:Excuter,assign_statement:AST)->Unit{
  whoAmI("excuteAssignStatement")

  match assign_statement {
    AssignStatementAST(variable,expression) => {
      self.line=variable.line

      let expression_value=self.excuteExpression(expression)

      if not(self.vartable_stack[self.vartable_stack.length()-1].set(variable.lexeme,expression_value)){
        self.symbolError("The variable: "+variable.lexeme+" is undefined")
      }
    }
    _ => ()
  }

}

fn Excuter::excuteRetuerStatement(self:Excuter,return_statement:AST)->Unit{
  whoAmI("excuteRetuerStatement")

  match return_statement{
    ReturnStatementAST(Some(expression)) => {
      self.return_value=self.excuteExpression(expression)
    }
    ReturnStatementAST(None) => {
      self.return_value=error_number
    }
    _ => ()
  }

  self.is_returned=true
}

fn Excuter::excutePrintStatement(self:Excuter,print_statement:AST)->Unit{
  whoAmI("excutePrintStatement")

  match print_statement {
    PrintStatementAST(expression) => {
      let expression_value=self.excuteExpression(expression)
      if not(self.is_error){println(expression_value)}
    }
    _ => ()
  }
}

fn Excuter::excuteExpressionStatement(self:Excuter,expression_statement:AST)->Unit{
  whoAmI("excuteExpressionStatement")

  match expression_statement {
    ExpressionStatementAST(expression) => {let x=self.excuteExpression(expression)}
    _ => ()
  }
}



// Expression
fn Excuter::excuteExpression(self:Excuter,expression:AST)->Int{
  whoAmI("excuteExpression")
  
  match expression{
    ExpressionAST(plusminus_expression) => self.excutePlusMinusExpression(plusminus_expression)
    _ => error_number
  }
}

fn Excuter::excutePlusMinusExpression(self:Excuter,plusminus_expression:AST)->Int{
  whoAmI("excutePlusMinusExpression")
  
  match plusminus_expression {
    PlusMinusExpressionAST(muldiv_expressions,infix_operators) => {
      let mut value=self.excuteMulDivExpression(muldiv_expressions[0])
      
      for i=0;i<infix_operators.length();i=i+1{
        let temp=self.excuteMulDivExpression(muldiv_expressions[i+1])
        
        match infix_operators[i].t_type{
          PLUS => value+=temp
          MINUS => value-=temp
          _ => ()
        }
      }
    
      value
    }
    _ => error_number
  }
}

fn Excuter::excuteMulDivExpression(self:Excuter,muldiv_expression:AST)->Int{
  whoAmI("excuteMulDivExpression")
  
  match muldiv_expression {
    MulDiveExpressionAST(unary_expressions,infix_operators) => {
      let mut value=self.excuteUnaryExpression(unary_expressions[0])
      
      for i=0;i<infix_operators.length();i=i+1{
        let temp=self.excuteUnaryExpression(unary_expressions[i+1])
        
        match infix_operators[i].t_type{
          MUL => value*=temp
          DIV => value/=temp
          MOD => value%=temp
          _ => ()
        }
      }
      
      value
    }
    _ => error_number
  }
}

fn Excuter::excuteUnaryExpression(self:Excuter,unary_expression:AST)->Int{
  whoAmI("excuteUnaryExpression")
  
  match unary_expression {
    UnaryExpressionAST(prefix_operator,x_expression) => {
      let mut value=match x_expression{
        PrimaryExpressionAST(_) => self.excutePrimaryExpression(x_expression)
        FunctionCallExpressionAST(_) => self.excuteFunctionCallExpression(x_expression)
        _ => error_number
      }
      
      match prefix_operator {
        Some(t) => match t.t_type {MINUS => value=-value;_=>()}
        None => ()
      }

      value
    }
    _ => error_number
  }
}

fn Excuter::excutePrimaryExpression(self:Excuter,primary_expression:AST)->Int{
  whoAmI("excutePrimaryExpression")
  
  match primary_expression {
    PrimaryExpressionAST(Some(expression),None,None) => self.excuteExpression(expression)

    PrimaryExpressionAST(None,Some(variable),None) => {
      self.line=variable.line
      match self.vartable_stack[self.vartable_stack.length()-1].get(variable.lexeme){
        Ok(value) => value
        Err(_) => {
          self.symbolError("The variable: "+variable.lexeme+" is undefined")
          error_number
        }
      }
    }
    
    PrimaryExpressionAST(None,None,Some(value_int)) => value_int
    _ => error_number
  }
}

fn Excuter::excuteFunctionCallExpression(self:Excuter,funcall_expression:AST)->Int{
  whoAmI("excuteFunctionCallExpression")

  match funcall_expression{
    FunctionCallExpressionAST(function,expressions) => {
      let arguments=@vec.Vec::new()
      expressions.iter(
        fn(expression){
          arguments.push(self.excuteExpression(expression))
        }
      )

      self.line=function.line
      match self.functable.get(function.lexeme){
        Ok(target_function) => {
          if target_function.parameters.length()!=arguments.length(){
            self.otherError("The function call: "+function.lexeme+"'s parameter and argument number is not equal")
            return error_number
          }

          self.excuteFunction(target_function,arguments)
          self.is_returned=false
          self.return_value
        }
        Err(_) => {
          self.symbolError("The function: "+function.lexeme+" is undefined")
          error_number
        }
      }

    }
    _ => error_number
  }
}