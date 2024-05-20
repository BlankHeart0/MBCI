struct Parser {
  tokens:@vec.Vec[Token]
  mut current:Int
  mut line:Int
  mut is_error:Bool
}



// Translation Unit
fn Parser::parseTranslationUnit(self:Parser)->Result[AST,Unit]{
  whoAmI("parseTranslationUnit")

  let function_definitions=@vec.Vec::new()
  
  while not(self.isAtEnd()||self.isAtEnd()){
    function_definitions.push(self.parseFunctionDefinition()?)
  }

  Ok(TranslationUnitAST(function_definitions))
}



// Definition
fn Parser::parseFunctionDefinition(self:Parser)->Result[AST,Unit]{
  whoAmI("parseFunctionDefinition")

  if self.mattch(VOID)||self.mattch(INT){
    let ret_type=self.consumed()
    
    if self.mattch(IDENTIFIER){
      let function_name=self.consumed()

      if self.mattch(LEFT_PAREN){
        if self.mattch(RIGHT_PAREN){
          let compound_statement=self.parseCompoundStatement()?

          Ok(FunctionDefinitionAST(ret_type,function_name,compound_statement))
        }
        else {self.parseError("Right paren ')' loss");Err(())}
      }
      else {self.parseError("Left paren '(' loss");Err(())}
    }
    else {self.parseError("Function name loss");Err(())}
  }
  else {self.parseError("Function return type loss");Err(())}
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
    if self.peek1(INT) {self.parseLocalVariableDefinition()?}
    else if self.peek1(LEFT_BRACE){self.parseCompoundStatement()?}
    else if self.peek1(IDENTIFIER)&& self.peekN(ASSIGN,2){self.parseAssignStatement()?}
    else if self.peek1(PRINT){self.parsePrintStatement()?}
    else {self.parseExpressionStatement()?}

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

fn Parser::parsePrintStatement(self:Parser)->Result[AST,Unit]{
  whoAmI("parsePrintStatement")

  if self.mattch(PRINT){
    let expression=self.parseExpression()?
    self.mattchSemicolon()

    Ok(PrintStatementAST(expression))
  }
  else {self.parseError("Keyword 'print' loss");Err(())}
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

  let plusminus_expression=self.parsePlusMinusExpression()?

  Ok(ExpressionAST(plusminus_expression))
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
    if self.mattch(MINUS) {Some(self.consumed())}
    else {None}
  
  let primary_expression=self.parsePrimaryExpression()?

  Ok(UnaryExpressionAST(prefix_operator,primary_expression))
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