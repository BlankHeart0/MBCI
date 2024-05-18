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

fn AST::astPrint(self:AST,depth:Int)->Unit{

  fn tabPrint(n:Int){for i=0;i<n;i=i+1{print("\t")}}
  fn deepPrintln(something:String){tabPrint(depth+1);println(something)}
  fn childrenPrint(child:AST){child.astPrint(depth+1)}
  
  tabPrint(depth)

  match self {
    // Translation Unit
    TranslationUnitAST(function_definitions) => {
      println("TranslationUnitAST")
      function_definitions.iter(childrenPrint)
    }
      
    // Definition
    FunctionDefinitionAST(ret_type,function_name,compound_statement) => {
      print("FunctionDefinitionAST")
      print(" ret_type:"+ret_type.lexeme)
      println(" function_name:"+function_name.lexeme)
      compound_statement.astPrint(depth+1)
    }

    // Statement
    StatementAST(x_statement) => {
      println("StatementAST")
      x_statement.astPrint(depth+1)
    }

    CompoundStatementAST(statements) => {
      println("CompoundStatementAST")
      statements.iter(childrenPrint)
    }

    PrintStatementAST(expression) => {
      println("PrintStatementAST")
      expression.astPrint(depth+1)
    }

    ExpressionStatementAST(expression) => {
      println("ExpressionStatementAST")
      expression.astPrint(depth+1)
    }

    // Expression
    ExpressionAST(plusminus_expression) => {
      println("ExpressionAST")
      plusminus_expression.astPrint(depth+1)
    }

    PlusMinusExpressionAST(muldiv_expressions,infix_operators) => {
      println("PlusMinusExpressionAST")
      muldiv_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        muldiv_expressions[i+1].astPrint(depth+1)
      }
    }

    MulDiveExpressionAST(unary_expressions,infix_operators) => {
      println("MulDiveExpressionAST")
      unary_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        unary_expressions[i+1].astPrint(depth+1)
      }
    }

    UnaryExpressionAST(prefix_operator_option,primary_expression) => {
      println("UnaryExpressionAST")
      match prefix_operator_option {
        Some(prefix_operator) => match prefix_operator.t_type{
          MINUS => deepPrintln(" prefix_operator:"+prefix_operator.lexeme)
          _ => ()
        }
        _ => ()
      }
      primary_expression.astPrint(depth+1)
    }

    PrimaryExpressionAST(expression_option,constantInt_option) => {
      println("PrimaryExpressionAST")
      match expression_option {
        Some(expression) => expression.astPrint(depth+1)
        _ => match constantInt_option {
              Some(value_int) => deepPrintln(" value_int:"+value_int.to_string())
              _=> ()
            }
      }
    }
  }
}