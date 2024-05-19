struct Excuter {
  ast:AST
  functable:FunctionTable
  mut line:Int
  mut is_error:Bool
}



fn Excuter::excute(self:Excuter)->Unit{
  self.loadTranslationUnit()

  self.line=0
  if not(self.is_error){
    match self.functable.get("main"){
      Ok(main) => self.excuteFunction(main)
      Err(_) => self.otherError("Can not find 'main' function") 
    }
  }
}

fn Excuter::excuteFunction(self:Excuter,function:Function)->Unit{
  whoAmI("excuteFunction")
  //@Todo: parameter bind
  self.excuteCompoundStatement(function.body)
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
    FunctionDefinitionAST(ret_type,function_name,compound_statement) => {
      self.line=function_name.line

      let new_function:Function={
        ret_type:match ret_type.t_type {VOID=>R_Void;INT=>R_Int},
        name:function_name.lexeme,
        body:compound_statement,
        parameters:@vec.Vec::new(),//@Todo
        vartable:VariableTable::new()
      }

      if not(self.functable.add(new_function)){
        self.symbolError("The function: "+function_name.lexeme+" is redefined")
      }
    }

    _ => ()
  }
}



// Statement
fn Excuter::excuteStatement(self:Excuter,statement:AST)->Unit{
  whoAmI("excuteStatement")

  match statement {
    StatementAST(x_statement) => 
      match x_statement {
        CompoundStatementAST(_) => self.excuteCompoundStatement(x_statement)
        PrintStatementAST(_) => self.excutePrintStatement(x_statement)
        ExpressionAST(_) => self.excuteExpressionStatement(x_statement)
        _ => ()
      }
    _ => ()
  }
}

fn Excuter::excuteCompoundStatement(self:Excuter,compound_statement:AST)->Unit{
  whoAmI("excuteCompoundStatement")

  match compound_statement {
    CompoundStatementAST(statements) => 
      statements.iter(
        fn(statement){
          self.excuteStatement(statement)
        }
      )
    _=>()
  }
}

fn Excuter::excutePrintStatement(self:Excuter,print_statement:AST)->Unit{
  whoAmI("excutePrintStatement")

  match print_statement {
    PrintStatementAST(expression) => println(self.excuteExpression(expression))
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
  match expression{
    ExpressionAST(plusminus_expression) => self.excutePlusMinusExpression(plusminus_expression)
    _ => error_number
  }
}

fn Excuter::excutePlusMinusExpression(self:Excuter,plusminus_expression:AST)->Int{
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
  match unary_expression {
    UnaryExpressionAST(prefix_operator,primary_expression) => {
      let mut value=self.excutePrimaryExpression(primary_expression)
      
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
  match primary_expression {
    PrimaryExpressionAST(Some(expression),None) => self.excuteExpression(expression)
    PrimaryExpressionAST(None,Some(value_int)) => value_int
    _ => error_number
  }
}
