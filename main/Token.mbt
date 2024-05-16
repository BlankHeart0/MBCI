enum TokenType{
  //Keyword
  INT
  PRINT
  IF; ELSE
  WHILE; DO; FOR
  CONTINUE; BREAK
  RETURN

  //Separator
  SEMICOLON; COMMA // ; ,
  LEFT_PAREN; RIGHT_PAREN // ( )
  LEFT_SQUARE; RIGHT_SQUARE // [ ]
  LEFT_BRACE; RIGHT_BRACE // { }

  //Operator
  PLUS; MINUS; STAR; SLASH; PERCENT // + - * / %
  ASSIGN // =
  EQUAL; NOT_EQUAL // == !=
  LESS; LESS_EQUAL // < <=
  GREATER; GREATER_EQUAL // > >=
  NOT; AND; OR// ! && ||

  //Constant
  CONSTANT_INT(Int)

  //Identifier
	IDENTIFIER

  CODE_EOF
}

let keywordMap:@hashmap.HashMap[String,TokenType]=
  @hashmap.HashMap::[
    ("int",INT),
    ("print",PRINT),
    ("if",IF),("else",ELSE),
    ("while",WHILE),("do",DO),("for",FOR),
    ("continue",CONTINUE),("break",BREAK),
    ("return",RETURN)
  ]

struct Token {
  t_type:TokenType
  line:Int
  lexeme:String
}

fn getTokenStr(self:TokenType)->String{
  match self{
  //Keyword
  INT => "INT"
  PRINT => "PRINT"
  IF => "IF"; ELSE => "ELSE"
  WHILE => "WHILE"; DO => "DO"; FOR => "FOR"
  CONTINUE => "CONTINUE"; BREAK => "BREAK"
  RETURN => "RETURN"

  //Separator
  SEMICOLON => "SEMICOLON"; COMMA => "COMMA" // ; ,
  LEFT_PAREN => "LEFT_PAREN"; RIGHT_PAREN => "RIGHT_PAREN" // ( )
  LEFT_SQUARE => "LEFT_SQUARE"; RIGHT_SQUARE => "RIGHT_SQUARE" // [ ]
  LEFT_BRACE => "LEFT_BRACE"; RIGHT_BRACE => "RIGHT_BRACE" // { }

  //Operator
  PLUS => "PLUS"; MINUS => "MINUS"; STAR => "STAR"; SLASH => "SLASH"; PERCENT => "PERCENT" // + - * / %
  ASSIGN => "ASSIGN" // =
  EQUAL => "EQUAL"; NOT_EQUAL => "NOT_EQUAL" // == !=
  LESS => "LESS"; LESS_EQUAL => "LESS_EQUAL" // < <=
  GREATER => "GREATER"; GREATER_EQUAL => "GREATER_EQUAL" // > >=
  NOT => "NOT"; AND => "AND"; OR => "OR"// ! && ||

  //Constant
  CONSTANT_INT(value_int) => "CONSTANT_INT\t"+value_int.to_string()

  //Identifier
	IDENTIFIER => "IDENTIFIER"

  CODE_EOF => "CODE_EOF"
  }
}