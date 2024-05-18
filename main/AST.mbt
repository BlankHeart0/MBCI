enum AST{
  // Translation Unit
  TranslationUnitAST(@vec.Vec[AST])

  // Definition
  FunctionDefinitionAST(Token,Token,AST)

  // Statement
  StatementAST(AST)
  CompoundStatementAST(@vec.Vec[AST])
  PrintStatementAST(AST)
  ExpressionStatementAST(AST)
  
  // Expression
  ExpressionAST(AST)
  PlusMinusExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  MulDiveExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  UnaryExpressionAST(Option[Token],AST)
  PrimaryExpressionAST(Option[AST],Option[Int])
}
