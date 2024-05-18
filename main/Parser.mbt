struct Parser {
  tokens:@vec.Vec[Token]
  mut current:Int
  mut line:Int
  mut is_error:Bool
}



//Translation Unit
fn Parser::parseTranslationUnitAST(self:Parser)->AST{
  whoAmI("parseTranslationUnitAST")

  let statements=@vec.Vec::new()
  
  while not(self.isAtEnd()){
    statements.push(self.parseStatementAST())
  }

  TranslationUnitAST(statements)
}



//Statement
fn Parser::parseStatementAST(self:Parser)->AST{
  whoAmI("parseStatementAST")

  let statement=self.parsePrintStatementAST()

  statement
}

fn Parser::parsePrintStatementAST(self:Parser)->AST{
  whoAmI("parsePrintStatementAST")

  if not(self.mattch(PRINT)){self.parseError("Keyword 'print' loss")}
  let expression=self.parseExpressionAST()
  self.mattchSemicolon()

  PrintStatementAST(expression)
}



//Expression
fn Parser::parseExpressionAST(self:Parser)->AST{
  whoAmI("parseExpressionAST")

  let expression=self.parsePlusMinusExpressionAST()

  expression
}

fn Parser::parsePlusMinusExpressionAST(self:Parser)->AST{
  whoAmI("parsePlusMinusExpressionAST")

  let plusminus_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()
  
  plusminus_expressions.push(self.parseMulDiveExpressionAST())
  while self.mattch(PLUS)||self.mattch(MINUS){
    infix_operators.push(self.consumed())
    plusminus_expressions.push(self.parseMulDiveExpressionAST())
  }

  PlusMinusExpressionAST(plusminus_expressions,infix_operators)
}

fn Parser::parseMulDiveExpressionAST(self:Parser)->AST{
  whoAmI("parseMulDiveExpressionAST")

  let unary_expressions=@vec.Vec::new()
  let infix_operators=@vec.Vec::new()

  unary_expressions.push(self.parseUnaryExpressionAST())
  while self.mattch(MUL)||self.mattch(DIV)||self.mattch(MOD){
    infix_operators.push(self.consumed())
    unary_expressions.push(self.parseUnaryExpressionAST())
  }

  MulDiveExpressionAST(unary_expressions,infix_operators)
}

fn Parser::parseUnaryExpressionAST(self:Parser)->AST{
  whoAmI("parseUnaryExpressionAST")

  let prefix_operator:Option[Token]=
    if self.mattch(MINUS) {Some(self.consumed())}
    else {None}
  
  let primary_expression=self.parsePrimaryExpressionAST()

  UnaryExpressionAST(prefix_operator,primary_expression)
}

fn Parser::parsePrimaryExpressionAST(self:Parser)->AST{
  whoAmI("parsePrimaryExpressionAST")

  if self.mattch(LEFT_PAREN){
    let expression=self.parseExpressionAST()
    if not(self.mattch(RIGHT_PAREN)){self.parseError("Right paren ')' loss")}
    PrimaryExpressionAST(Some(expression),None)
  } else {
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