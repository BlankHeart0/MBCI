enum AST{
  // Translation Unit
  TranslationUnitAST(@vec.Vec[AST])
  
  // Statement
  StatementAST(AST)
  PrintStatementAST(AST)

  // Expression
  ExpressionAST(AST)
  PlusMinusExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  MulDiveExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  UnaryExpressionAST(Option[Token],AST)
  PrimaryExpressionAST(Option[AST],Option[Int])
}
