struct Parser {
  tokens:@vec.Vec[Token]
  mut current:Int
  mut line:Int
  mut is_void:Bool
  mut is_error:Bool
}



// Translation Unit
fn Parser::parseTranslationUnit(self:Parser)->Result[AST,Unit]{
  whoAmI("parseTranslationUnit")

  let definitions=@vec.Vec::new()
  
  while not(self.isAtEnd()){
    if self.peekN(LEFT_PAREN,3){
      definitions.push(self.parseFunctionDefinition()?)
    }
    else {definitions.push(self.parseGlobalVariableDefinition()?)}
  }

  Ok(TranslationUnitAST(definitions))
}



// Definition
fn Parser::parseFunctionDefinition(self:Parser)->Result[AST,Unit]{
  whoAmI("parseFunctionDefinition")

  if self.mattch(VOID)||self.mattch(INT){
    let ret_type=self.consumed()
    match ret_type.t_type{
      VOID => self.is_void=true
      _ => self.is_void=false
    }

    if self.mattch(IDENTIFIER){
      let function_name=self.consumed()

      if self.mattch(LEFT_PAREN){
        let parameters=@vec.Vec::new()

        if not(self.peek1(RIGHT_PAREN)){
          parameters.push(self.parseParameter()?)
          while self.mattch(COMMA){
            parameters.push(self.parseParameter()?)
          }
        }

        if self.mattch(RIGHT_PAREN){
          let compound_statement=self.parseCompoundStatement()?

          Ok(FunctionDefinitionAST(ret_type,function_name,parameters,compound_statement))
        }
        else {self.parseError("Right paren ')' loss");Err(())}
      }
      else {self.parseError("Left paren '(' loss");Err(())}
    }
    else {self.parseError("Function name loss");Err(())}
  }
  else {self.parseError("Function return type loss");Err(())}
}

fn Parser::parseParameter(self:Parser)->Result[AST,Unit]{
  whoAmI("parseParameter")

  if self.mattch(INT){
    let data_type=self.consumed()

    if self.mattch(IDENTIFIER){
      let parameter_name=self.consumed()

      Ok(ParameterAST(data_type,parameter_name))
    }
    else {self.parseError("Parameter name loss");Err(())}
  }
  else {self.parseError("Parameter type loss");Err(())}
}

fn Parser::parseGlobalVariableDefinition(self:Parser)->Result[AST,Unit]{
  whoAmI("parseGlobalVariableDefinition")

  if self.mattch(INT){
    let data_type=self.consumed()

    if self.mattch(IDENTIFIER){
      let variable_name=self.consumed()
      
      if self.mattch(ASSIGN){
        let negative=self.mattch(MINUS)
        
        match self.consuming().t_type{
          CONSTANT_INT(value_int) => {
            self.consume()
            self.mattchSemicolon()
            if negative{
              Ok(GlobalVariableDefinitionAST(data_type,variable_name,Some(-value_int)))
            }
            else {Ok(GlobalVariableDefinitionAST(data_type,variable_name,Some(value_int)))}
          }
          _ => {
            self.parseError("Global variable only can be initialized by constant")
            Err(())
          }
        }
      }
      else{
        self.mattchSemicolon()

        Ok(GlobalVariableDefinitionAST(data_type,variable_name,None))
      }
    }
    else {self.parseError("Variable name loss");Err(())}
  }
  else {self.parseError("Variable type loss");Err(())}
}

fn Parser::parseLocalVariableDefinition(self:Parser)->Result[AST,Unit]{
  whoAmI("parseLocalVariableDefinition")

  if self.mattch(INT){
    let data_type=self.consumed()

    if self.mattch(IDENTIFIER){
      let variable_name=self.consumed()

      if self.mattch(ASSIGN){
        let expression=self.parseExpression()?
        self.mattchSemicolon()
        
        Ok(LocalVariableDefinitionAST(data_type,variable_name,Some(expression)))
      }
      else {
        self.mattchSemicolon()

        Ok(LocalVariableDefinitionAST(data_type,variable_name,None))
      }
    }
    else {self.parseError("Variable name loss");Err(())}
  }
  else {self.parseError("Variable type loss");Err(())}
}



// Statement
fn Parser::parseStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseStatement")

  let x_statement:AST=
    if self.peek1(INT)            {self.parseLocalVariableDefinition()?}
    else if self.peek1(LEFT_BRACE){self.parseCompoundStatement()?}
    else if self.peek1(IDENTIFIER)&&
            self.peekN(ASSIGN,2)  {self.parseAssignStatement()?}
    else if self.peek1(IF)        {self.parseIfStatement()?}
    else if self.peek1(WHILE)     {self.parseWhileStatement()?}
    else if self.peek1(RETURN)    {self.parseReturnStatement()?}
    else if self.peek1(PRINTF)    {self.parsePrintfStatement()?}
    else                          {self.parseExpressionStatement()?}

  Ok(StatementAST(x_statement))
}

fn Parser::parseCompoundStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseCompoundStatement")

  let statements=@vec.Vec::new()
  if self.mattch(LEFT_BRACE){
    while not(self.mattch(RIGHT_BRACE)){
      statements.push(self.parseStatement()?)
    }

    match self.consumed().t_type{
      RIGHT_BRACE => Ok(CompoundStatementAST(statements))
      _ => {self.parseError("Right brace '}' loss");Err(())}
    } 
  }
  else {self.parseError("Left brace '{' loss");Err(())}
}

fn Parser::parseAssignStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseAssignStatement")

  if self.mattch(IDENTIFIER){
    let variable=self.consumed()

    if self.mattch(ASSIGN){
      let expression=self.parseExpression()?
      self.mattchSemicolon()

      Ok(AssignStatementAST(variable,expression))
    }
    else {self.parseError("Assign character '=' loss");Err(())}
  }
  else {self.parseError("Variable name loss");Err(())}

}

fn Parser::parseIfStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseIfStatement")
  
  if self.mattch(IF){
    if self.mattch(LEFT_PAREN){
      let expression=self.parseExpression()?

      if self.mattch(RIGHT_PAREN){
        let statement_true=self.parseStatement()?

        if self.mattch(ELSE){
          let statement_false=self.parseStatement()?

          Ok(IfStatementAST(expression,statement_true,Some(statement_false)))
        }
        else{Ok(IfStatementAST(expression,statement_true,None))}
      } 
      else {self.parseError("Right paren ')' loss");Err(())}
    }
    else {self.parseError("Left paren '(' loss");Err(())}
  }
  else {self.parseError("Keyword 'if' loss");Err(())}
}

fn Parser::parseWhileStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseWhileStatement")

  if self.mattch(WHILE){
    if self.mattch(LEFT_PAREN){
      let expression=self.parseExpression()?
      
      if self.mattch(RIGHT_PAREN){
        let statement=self.parseStatement()?

        Ok(WhileStatementAST(expression,statement))
      }
      else {self.parseError("Right paren ')' loss");Err(())}
    }
    else {self.parseError("Left paren '(' loss");Err(())}
  }
  else {self.parseError("Keyword 'while' loss");Err(())}
}

fn Parser::parseReturnStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseReturnStatement")

  if self.mattch(RETURN){
    if not(self.peek1(SEMICOLON)){
      if self.is_void{
        self.parseError("Void function can't return some value")
        return Err(())
      }

      let expression=self.parseExpression()?
      self.mattchSemicolon()

      Ok(ReturnStatementAST(Some(expression)))
    }
    else {
      if not(self.is_void){
        self.parseError("Non-void function can't return void")
        return Err(())
      }

      self.mattchSemicolon()

      Ok(ReturnStatementAST(None))
    }
  }
  else {self.parseError("Keyword 'return' loss");Err(())}
}

fn Parser::parsePrintfStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parsePrintfStatement")

  if self.mattch(PRINTF){
    if self.mattch(LEFT_PAREN){
      match self.consuming().t_type{
        CONSTANT_STR(_) => {
          self.consume()
          let constant_str=self.consumed()

          let expressions=@vec.Vec::new()
          while self.mattch(COMMA){
            expressions.push(self.parseExpression()?)
          }

          if self.mattch(RIGHT_PAREN){
            self.mattchSemicolon()
            Ok(PrintfStatementAST(constant_str,expressions))
          }
          else {self.parseError("Right paren ')' loss");Err(())}
        }

        _ => {
          self.parseError("Printf's format string loss")
          Err(())
        }
      }
    }
    else {self.parseError("Left paren '(' loss");Err(())}
  }
  else {self.parseError("Keyword 'printf' loss");Err(())}
}

fn Parser::parseExpressionStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parseExpressionStatement")

  let expression=self.parseExpression()?
  self.mattchSemicolon()

  Ok(ExpressionStatementAST(expression))
}



// Expression
fn Parser::parseExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseExpression")

  let logicOr_expression=self.parseLogicOrExpression()?

  Ok(ExpressionAST(logicOr_expression))
}

fn Parser::parseLogicOrExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseLogicOrExpression")
  
  let logicAnd_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()

  logicAnd_expressions.push(self.parseLogicAndExpression()?)
  while self.mattch(OR){
    infix_operators.push(self.consumed())
    logicAnd_expressions.push(self.parseLogicAndExpression()?)
  }

  Ok(LogicOrExpressionAST(logicAnd_expressions,infix_operators))
}

fn Parser::parseLogicAndExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseLogicAndExpression")

  let equlity_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  equlity_expressions.push(self.parseEqualityExpression()?)
  while self.mattch(AND){
    infix_operators.push(self.consumed())
    equlity_expressions.push(self.parseEqualityExpression()?)
  }

  Ok(LogicAndExpressionAST(equlity_expressions,infix_operators))
}

fn Parser::parseEqualityExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseEqualityExpression")

  let relational_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  relational_expressions.push(self.parseRelationalExpression()?)
  while self.mattch(EQUAL)||self.mattch(NOT_EQUAL){
    infix_operators.push(self.consumed())
    relational_expressions.push(self.parseRelationalExpression()?)
  }

  Ok(EqualityExpressionAST(relational_expressions,infix_operators))
}

fn Parser::parseRelationalExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseRelationalExpression")

  let plusminus_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  plusminus_expressions.push(self.parsePlusMinusExpression()?)
  while self.mattch(LESS)||self.mattch(LESS_EQUAL)||self.mattch(GREATER)||self.mattch(GREATER_EQUAL){
    infix_operators.push(self.consumed())
    plusminus_expressions.push(self.parsePlusMinusExpression()?)
  }

  Ok(RelationalExpressionAST(plusminus_expressions,infix_operators))
}

fn Parser::parsePlusMinusExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parsePlusMinusExpression")

  let muldiv_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  muldiv_expressions.push(self.parseMulDiveExpression()?)
  while self.mattch(PLUS)||self.mattch(MINUS){
    infix_operators.push(self.consumed())
    muldiv_expressions.push(self.parseMulDiveExpression()?)
  }

  Ok(PlusMinusExpressionAST(muldiv_expressions,infix_operators))
}

fn Parser::parseMulDiveExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseMulDiveExpression")

  let unary_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()

  unary_expressions.push(self.parseUnaryExpression()?)
  while self.mattch(MUL)||self.mattch(DIV)||self.mattch(MOD){
    infix_operators.push(self.consumed())
    unary_expressions.push(self.parseUnaryExpression()?)
  }

  Ok(MulDiveExpressionAST(unary_expressions,infix_operators))
}

fn Parser::parseUnaryExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseUnaryExpression")

  let prefix_operator:Option[Token]=
    if self.mattch(MINUS)||self.mattch(NOT) {Some(self.consumed())}
    else {None}
  
  let x_expression=
    if self.peek1(IDENTIFIER)&&self.peekN(LEFT_PAREN,2){
      self.parseFunctionCallExpression()?
    }
    else {self.parsePrimaryExpression()?}

  Ok(UnaryExpressionAST(prefix_operator,x_expression))
}

fn Parser::parsePrimaryExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parsePrimaryExpression")

  // "("<Expression>")"
  if self.mattch(LEFT_PAREN){
    let expression=self.parseExpression()?

    if self.mattch(RIGHT_PAREN){Ok(PrimaryExpressionAST(Some(expression),None,None))}
    else {self.parseError("Right paren ')' loss");Err(())}
  }
  // Variable
  else if self.mattch(IDENTIFIER){
    let variable=self.consumed()
    
    Ok(PrimaryExpressionAST(None,Some(variable),None))
  }
  // CONSTANT_INT
  else {
    match self.consuming().t_type{
      CONSTANT_INT(value_int) => {
        self.consume()
        Ok(PrimaryExpressionAST(None,None,Some(value_int)))
      }
      _ => {
        self.parseError("Primary expression loss")
        Err(())
      }
    }
  }
}

fn Parser::parseFunctionCallExpression(self:Parser)->Result[AST,Unit]{
  whoAmI("parseFunctionCallExpression")

  if self.mattch(IDENTIFIER){
    let function=self.consumed()

    if self.mattch(LEFT_PAREN){

      let expressions=@vec.Vec::new()
      if not(self.peek1(RIGHT_PAREN)){
        expressions.push(self.parseExpression()?)
        while self.mattch(COMMA){
          expressions.push(self.parseExpression()?)
        }
      }

      if self.mattch(RIGHT_PAREN){
        Ok(FunctionCallExpressionAST(function,expressions))
      }
      else {self.parseError("Right paren ')' loss");Err(())}
    }
    else {self.parseError("Left paren '(' loss");Err(())}
  }
  else {self.parseError("Function name loss");Err(())}
}



// tool function
fn Parser::isAtEnd(self:Parser)->Bool{
  if not(self.is_error){
    match self.consuming().t_type{
      CODE_EOF => true
      _ => false
    }
  }
  else {true}
}

fn Parser::consume(self:Parser)->Unit{
  self.current+=1
}

fn Parser::consuming(self:Parser)->Token{
  self.tokens[self.current]
}

fn Parser::consumed(self:Parser)->Token{
  self.tokens[self.current-1]
}

fn Parser::mattch(self:Parser,expected:TokenType)->Bool{
  if not(self.isAtEnd()) {
    let current_token=self.tokens[self.current]
    self.line=current_token.line
    
    if isSameTokenType(current_token.t_type,expected){
      self.consume()
      true
    }
    else {false}
  }
  else {false}
}

fn Parser::mattchSemicolon(self:Parser)->Unit{
  if not(self.mattch(SEMICOLON)){
    self.parseError("Semicolon ';' loss")
  }
}

fn Parser::peek1(self:Parser,expected:TokenType)->Bool{
  peekN(self,expected,1)
}

fn Parser::peekN(self:Parser,expected:TokenType,n:Int)->Bool{
  if self.current+n-1<self.tokens.length() {
    let peek_token=self.tokens[self.current+n-1]

    if isSameTokenType(peek_token.t_type,expected){true}
    else {false}
  }
  else {false}
}