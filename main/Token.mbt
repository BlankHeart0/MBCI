enum TokenType{
  //Keyword
  INT; VOID
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
  PLUS; MINUS; MUL; DIV; MOD // + - * / %
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
    ("int",INT),("void",VOID),
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
  INT => "INT"; VOID=>"VOID"
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
  PLUS => "PLUS"; MINUS => "MINUS"; MUL => "MUL"; DIV => "DIV"; MOD => "MOD" // + - * / %
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

fn isSameTokenType(token1type:TokenType,token2type:TokenType)->Bool{
  match token1type{
    INT => match token2type{INT=>true;_=>false}
    VOID => match token2type{VOID=>true;_=>false}
    PRINT => match token2type{PRINT=>true;_=>false}
    IF => match token2type{IF=>true;_=>false}
    ELSE => match token2type{ELSE=>true;_=>false}
    WHILE => match token2type{WHILE=>true;_=>false}
    DO => match token2type{DO=>true;_=>false}
    FOR => match token2type{FOR=>true;_=>false}
    CONTINUE => match token2type{CONTINUE=>true;_=>false}
    BREAK => match token2type{BREAK=>true;_=>false}
    RETURN => match token2type{RETURN=>true;_=>false}
    SEMICOLON => match token2type{SEMICOLON=>true;_=>false}
    COMMA => match token2type{COMMA=>true;_=>false}
    LEFT_PAREN => match token2type{LEFT_PAREN=>true;_=>false}
    RIGHT_PAREN => match token2type{RIGHT_PAREN=>true;_=>false}
    LEFT_SQUARE => match token2type{LEFT_SQUARE=>true;_=>false}
    RIGHT_SQUARE => match token2type{RIGHT_SQUARE=>true;_=>false}
    LEFT_BRACE => match token2type{LEFT_BRACE=>true;_=>false}
    RIGHT_BRACE => match token2type{RIGHT_BRACE=>true;_=>false}
    PLUS => match token2type{PLUS=>true;_=>false}
    MINUS => match token2type{MINUS=>true;_=>false}
    MUL => match token2type{MUL=>true;_=>false}
    DIV => match token2type{DIV=>true;_=>false}
    MOD => match token2type{MOD=>true;_=>false}
    ASSIGN => match token2type{ASSIGN=>true;_=>false}
    EQUAL => match token2type{EQUAL=>true;_=>false}
    NOT_EQUAL => match token2type{NOT_EQUAL=>true;_=>false}
    LESS => match token2type{LESS=>true;_=>false}
    LESS_EQUAL => match token2type{LESS_EQUAL=>true;_=>false}
    GREATER => match token2type{GREATER=>true;_=>false}
    GREATER_EQUAL => match token2type{GREATER_EQUAL=>true;_=>false}
    NOT => match token2type{NOT=>true;_=>false}
    AND => match token2type{AND=>true;_=>false}
    OR => match token2type{OR=>true;_=>false}
    CONSTANT_INT(_) => match token2type{CONSTANT_INT(_)=>true;_=>false}
    IDENTIFIER => match token2type{IDENTIFIER=>true;_=>false}
    CODE_EOF => match token2type{CODE_EOF=>true;_=>false}
  }
}