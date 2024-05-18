struct Parser {
  tokens:@vec.Vec[Token]
  mut current:Int
  mut line:Int
  mut is_error:Bool
}



// Translation Unit
fn Parser::parseTranslationUnit(self:Parser)->AST{
  whoAmI("parseTranslationUnit")

  let statements=@vec.Vec::new()
  
  while not(self.isAtEnd()){
    statements.push(self.parseStatement())
  }

  TranslationUnitAST(statements)
}



// Statement
fn Parser::parseStatement(self:Parser)->AST{
  whoAmI("parseStatement")

  let x_statement=self.parsePrintStatement()

  StatementAST(x_statement)
}

fn Parser::parsePrintStatement(self:Parser)->AST{
  whoAmI("parsePrintStatement")

  if not(self.mattch(PRINT)){self.parseError("Keyword 'print' loss")}
  let expression=self.parseExpression()
  self.mattchSemicolon()

  PrintStatementAST(expression)
}



// Expression
fn Parser::parseExpression(self:Parser)->AST{
  whoAmI("parseExpression")

  let plusminus_expression=self.parsePlusMinusExpression()

  ExpressionAST(plusminus_expression)
}

fn Parser::parsePlusMinusExpression(self:Parser)->AST{
  whoAmI("parsePlusMinusExpression")

  let muldiv_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  muldiv_expressions.push(self.parseMulDiveExpression())
  while self.mattch(PLUS)||self.mattch(MINUS){
    infix_operators.push(self.consumed())
    muldiv_expressions.push(self.parseMulDiveExpression())
  }

  PlusMinusExpressionAST(muldiv_expressions,infix_operators)
}

fn Parser::parseMulDiveExpression(self:Parser)->AST{
  whoAmI("parseMulDiveExpression")

  let unary_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()

  unary_expressions.push(self.parseUnaryExpression())
  while self.mattch(MUL)||self.mattch(DIV)||self.mattch(MOD){
    infix_operators.push(self.consumed())
    unary_expressions.push(self.parseUnaryExpression())
  }

  MulDiveExpressionAST(unary_expressions,infix_operators)
}

fn Parser::parseUnaryExpression(self:Parser)->AST{
  whoAmI("parseUnaryExpression")

  let prefix_operator:Option[Token]=
    if self.mattch(MINUS) {Some(self.consumed())}
    else {None}
  
  let primary_expression=self.parsePrimaryExpression()

  UnaryExpressionAST(prefix_operator,primary_expression)
}

fn Parser::parsePrimaryExpression(self:Parser)->AST{
  whoAmI("parsePrimaryExpression")

  // "("<Expression>")"
  if self.mattch(LEFT_PAREN){
    let expression=self.parseExpression()
    if not(self.mattch(RIGHT_PAREN)){self.parseError("Right paren ')' loss")}
    
    PrimaryExpressionAST(Some(expression),None)
  }
  // CONSTANT_INT
  else {
    match self.consuming().t_type{
      CONSTANT_INT(value_int) => {
        self.consume()
        PrimaryExpressionAST(None,Some(value_int))
      }
      _ => {
        self.parseError("Primary expression loss")
        PrimaryExpressionAST(None,None)
      }
    }
  }
}



// tool function
fn Parser::isAtEnd(self:Parser)->Bool{
  if not(self.is_error){
    match self.tokens[self.current].t_type{
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