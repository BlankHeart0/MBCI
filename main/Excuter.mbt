struct Excuter {
  ast:AST
  mut line:Int
  mut is_error:Bool
}


// // Translation Unit
// fn AST::excuteTranslationUnit(self:AST)->Unit{
//   match self {
//     TranslationUnitAST(statements) => 
//       statements.iter(fn(statement){statement.excuteStatement()})
    
//     _ => excuteError("Unexpected AST")
//   }
// }



// // Statement
// fn AST::excuteStatement(self:AST)->Unit{
//   match self {
//     StatementAST(x_statement) => 
//       match x_statement {
//         PrintStatementAST(_) => x_statement.excutePrintStatement()
        
//         _ => excuteError("Unexpected AST")
//       }

//     _ => excuteError("Unexpected AST")
//   }
// }

// fn AST::excutePrintStatement(self:AST)->Unit{
//   match self {
//     PrintStatementAST(expression) => println(expression.excuteExpression())
    
//     _ => excuteError("Unexpected AST")
//   }
// }



// // Expression
// fn AST::excuteExpression(self:AST)->Int{
//   match self{
//     ExpressionAST(plusminus_expressionexpression) => plusminus_expressionexpression.excutePlusMinusExpression()
    
//     _ => error_number
//   }
// }

// fn AST::excutePlusMinusExpression(self:AST)->Int{
//   match self {
//     PlusMinusExpressionAST(muldiv_expressions,infix_operators) => {
//       let mut value=muldiv_expressions[0].excuteMulDivExpression()
      
//       for i=0;i<infix_operators.length();i=i+1{
//         let temp=muldiv_expressions[i+1].excuteMulDivExpression()
        
//         match infix_operators[i].t_type{
//           PLUS => value+=temp
//           MINUS => value-=temp

//           _ => excuteError("Unexpected operator")
//         }
//       }
      
//       value
//     }

//     _ => error_number
//   }
// }

// fn AST::excuteMulDivExpression(self:AST)->Int{
//   match self {
//     MulDiveExpressionAST(unary_expressions,infix_operators) => {
//       let mut value=unary_expressions[0].excuteUnaryExpression()
      
//       for i=0;i<infix_operators.length();i=i+1{
//         let temp=unary_expressions[i+1].excuteUnaryExpression()
        
//         match infix_operators[i].t_type{
//           MUL => value*=temp
//           DIV => value/=temp
//           MOD => value%=temp

//           _ => excuteError("Unexpected operator")
//         }
//       }
      
//       value
//     }

//     _ => error_number
//   }
// }

// fn AST::excuteUnaryExpression(self:AST)->Int{
//   match self {
//     UnaryExpressionAST(prefix_operator,primary_expression) => {
//       let value=primary_expression.excutePrimaryExpression()
      
//       match prefix_operator {
//         Some(t) => match t.t_type {
//           MINUS => -value

//           _ => error_number
//         }
//         None => value
//       }
//     }

//     _ => error_number
//   }
// }

// fn AST::excutePrimaryExpression(self:AST)->Int{
//   match self {
//     PrimaryExpressionAST(Some(expression),None) => expression.excuteExpression()
//     PrimaryExpressionAST(None,Some(value_int)) => value_int
    
//     _ => error_number
//   }
// }
