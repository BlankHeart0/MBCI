enum AST{
  // Translation Unit
  TranslationUnitAST(@vec.Vec[AST])

  // Definition
  FunctionDefinitionAST(Token,Token,@vec.Vec[AST],AST)
  ParameterAST(Token,Token)  
  GlobalVariableDefinitionAST(Token,Token,Option[Int])
  LocalVariableDefinitionAST(Token,Token,Option[AST])

  // Statement
  StatementAST(AST)
  CompoundStatementAST(@vec.Vec[AST])
  AssignStatementAST(Token,AST)
  IfStatementAST(AST,AST,Option[AST])
  WhileStatementAST(AST,AST)
  ReturnStatementAST(Option[AST])
  PrintfStatementAST(Token,@vec.Vec[AST])
  ExpressionStatementAST(AST)

  // Expression
  ExpressionAST(AST)
  LogicOrExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  LogicAndExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  EqualityExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  RelationalExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  PlusMinusExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  MulDiveExpressionAST(@vec.Vec[AST],@vec.Vec[Token])
  UnaryExpressionAST(Option[Token],AST)
  PrimaryExpressionAST(Option[AST],Option[Token],Option[Int])
  FunctionCallExpressionAST(Token,@vec.Vec[AST])
}

fn AST::astPrint(self:AST,depth:Int)->Unit{

  fn tabPrint(n:Int){for i=0;i<n;i=i+1{print("\t")}}
  fn deepPrintln(something:String){tabPrint(depth+1);println(something)}
  fn childrenPrint(child:AST){child.astPrint(depth+1)}
  
  tabPrint(depth)

  match self {
    // Translation Unit
    TranslationUnitAST(definitions) => {
      println("TranslationUnitAST")
      definitions.iter(childrenPrint)
    }
      
    // Definition
    FunctionDefinitionAST(ret_type,function_name,parameters,compound_statement) => {
      print("FunctionDefinitionAST")
      print(" ret_type:"+ret_type.lexeme)
      println(" function_name:"+function_name.lexeme)
      parameters.iter(childrenPrint)
      compound_statement.astPrint(depth+1)
    }
    
    ParameterAST(data_type,parameter_name) => {
      print("ParameterAST")
      print(" data_type:"+data_type.lexeme)
      println(" parameter_name:"+parameter_name.lexeme)
    }

    GlobalVariableDefinitionAST(data_type,variable_name,constantInt_option) => {
      print("GlobalVariableDefinitionAST")
      print(" data_type:"+data_type.lexeme)
      println(" variable_name:"+variable_name.lexeme)
      match constantInt_option {
        Some(value_int) => {
          deepPrintln(" INITIALIZE =")
          deepPrintln(value_int.to_string())
        }
        None => ()
      }
    }
    
    LocalVariableDefinitionAST(data_type,variable_name,expression_option) => {
      print("LocalVariableDefinitionAST")
      print(" data_type:"+data_type.lexeme)
      println(" variable_name:"+variable_name.lexeme)
      match expression_option {
        Some(expression) => {
          deepPrintln(" INITIALIZE =")
          expression.astPrint(depth+1)
        }
        None => ()
      }
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

    AssignStatementAST(variable,expression) => {
      print("AssignStatementAST")
      println(" variale:"+variable.lexeme)
      deepPrintln(" ASSIGN =")
      expression.astPrint(depth+1)
    }

    IfStatementAST(expression,statement_true,statement_option) => {
      println("IfStatementAST")
      expression.astPrint(depth+1)
      deepPrintln("TRUE BRANCH")
      statement_true.astPrint(depth+1)
      match statement_option{
        Some(statement_false) => {
          deepPrintln("FALSE BRANCH")
          statement_false.astPrint(depth+1) 
        }
        None => ()
      }
    }
    
    WhileStatementAST(expression,statement) => {
      println("WhileStatementAST")
      expression.astPrint(depth+1)
      statement.astPrint(depth+1)
    }
    
    ReturnStatementAST(expression_option) => {
      println("ReturnStatementAST")
      match expression_option {
        Some(expression) => {
          deepPrintln(" RETURN value")
          expression.astPrint(depth+1)
        }
        None => ()
      }
    }

    PrintfStatementAST(constant_str,expressions) => {
      print("PrintfStatementAST")
      println(" format_string:"+constant_str.lexeme)
      expressions.iter(childrenPrint)
    }

    ExpressionStatementAST(expression) => {
      println("ExpressionStatementAST")
      expression.astPrint(depth+1)
    }

    // Expression
    ExpressionAST(logicOr_expression) => {
      println("ExpressionAST")
      logicOr_expression.astPrint(depth+1)
    }

    LogicOrExpressionAST(logicAnd_expressions,infix_operators) => {
      println("LogicOrExpressionAST")
      logicAnd_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        logicAnd_expressions[i+1].astPrint(depth+1)
      }
    }

    LogicAndExpressionAST(equlity_expressions,infix_operators) => {
      println("LogicAndExpressionAST")
      equlity_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        equlity_expressions[i+1].astPrint(depth+1)
      }
    }

    EqualityExpressionAST(relational_expressions,infix_operators) => {
      println("EqualityExpressionAST")
      relational_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        relational_expressions[i+1].astPrint(depth+1)
      }
    }

    RelationalExpressionAST(plusminus_expressions,infix_operators) => {
      println("RelationalExpressionAST")
      plusminus_expressions[0].astPrint(depth+1)
      for i=0;i<infix_operators.length();i=i+1{
        deepPrintln(" infix_operator:"+infix_operators[i].lexeme)
        plusminus_expressions[i+1].astPrint(depth+1)
      }
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

    UnaryExpressionAST(prefix_operator_option,x_expression) => {
      println("UnaryExpressionAST")
      match prefix_operator_option {
        Some(prefix_operator) => match prefix_operator.t_type{
          MINUS | NOT => deepPrintln(" prefix_operator:"+prefix_operator.lexeme)
          _ => ()
        }
        _ => ()
      }
      x_expression.astPrint(depth+1)
    }

    PrimaryExpressionAST(expression_option,variable_option,constantInt_option) => {
      println("PrimaryExpressionAST")
      match expression_option {
        Some(expression) => expression.astPrint(depth+1)
        _ => match variable_option {
          Some(variable) => deepPrintln(" variable:"+variable.lexeme)
          _ =>match constantInt_option {
            Some(value_int) => deepPrintln(" value_int:"+value_int.to_string())
            _=> ()
          }
        } 
      }
    }

    FunctionCallExpressionAST(function,expressions) => {
      print("FunctionCallExpressionAST")
      println(" function:"+function.lexeme)
      expressions.iter(childrenPrint)
    }

  }
}