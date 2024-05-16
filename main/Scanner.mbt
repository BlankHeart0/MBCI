struct Scanner {
  source:String
  mut start:Int
  mut current:Int
  mut line:Int
  mut is_error:Bool
}

fn Scanner::scan(self:Scanner)->@vec.Vec[Token]{
  let tokens:@vec.Vec[Token]=@vec.Vec::new();
  
  fn addToken(t_type:TokenType){
    let token:Token={
      t_type:t_type,
      line:self.line,
      lexeme:
        match t_type{
          CODE_EOF => ""
          _ => self.source.substring(start=self.start,end=self.current)
        }
    }
    tokens.push(token)    
  }

  while not(self.isAtEnd()||self.is_error){
    self.start=self.current

    let c=self.advance()
    match c{
      //Separator
      ';' => addToken(SEMICOLON)
      ',' => addToken(COMMA)
      '(' => addToken(LEFT_PAREN)
      ')' => addToken(RIGHT_PAREN)
      '[' => addToken(LEFT_SQUARE)
      ']' => addToken(RIGHT_SQUARE)
      '{' => addToken(LEFT_BRACE)
      '}' => addToken(RIGHT_BRACE)

      //Operator
      '+' => addToken(PLUS)
      '-' => addToken(MINUS)
      '*' => addToken(MUL)
      '%' => addToken(MOD)
      '=' => addToken(if self.mattch('='){EQUAL}        else{ASSIGN})
      '!' => addToken(if self.mattch('='){NOT_EQUAL}    else{NOT})
      '<' => addToken(if self.mattch('='){LESS_EQUAL}   else{LESS})
      '>' => addToken(if self.mattch('='){GREATER_EQUAL}else{GREATER})
      '&' => if self.mattch('&'){addToken(AND)} else {self.scanError("Only '&' is illegal")} 
      '|' => if self.mattch('|'){addToken(OR)}  else {self.scanError("Only '|' is illegal")}
      
      //Comment
      '/' => if self.mattch('/'){ while not(self.isAtEnd())&&self.peek1()!='\n' {self.current+=1}}
             else if self.mattch('*'){
              while not(self.isAtEnd())&&(self.consumed()!='*'||self.peek1()!='/'){
                if self.peek1()=='\n' {self.line+=1}
                self.current+=1
              }
              if self.isAtEnd(){self.scanError("Incomplete multi-line comment")}
              else {self.current+=1}
             }
             else {addToken(DIV)}

      //Blank
      ' '|'\r'|'\t' => continue
      '\n' => self.line+=1
      
      //Number
       _  => if isDigit(c){addToken(self.scanNumber())}
      //Identifier and Keyword
           else if isAlphaUnderline(c){addToken(self.scanIdentifierKeyword())}
      //Error
           else {self.scanError("Unexpected character '"+c.to_string()+"'")}

    }
  }

  addToken(CODE_EOF)

  tokens
}

fn Scanner::scanNumber(self:Scanner)->TokenType{
  let mut value_int=self.consumed().to_int()-'0'.to_int()

  while not(self.isAtEnd())&&isDigit(self.peek1()){
    value_int=value_int*10+self.source[self.current].to_int()-'0'.to_int()
    self.current+=1
  }

  CONSTANT_INT(value_int)
}

fn Scanner::scanIdentifierKeyword(self:Scanner)->TokenType{
  while not(self.isAtEnd())&&isDigitAlphaUnderline(self.peek1()){
    self.current+=1
  }
  let text=self.source.substring(start=self.start,end=self.current)

  match keywordMap.get(text){
    Some(t_type) => t_type
    None => IDENTIFIER
  }  
}



// tool function
fn Scanner::isAtEnd(self:Scanner)->Bool{
  if self.current>=self.source.length() {true} 
  else {false}
}

fn Scanner::consumed(self:Scanner)->Char{
  self.source[self.current-1]
}

fn Scanner::advance(self:Scanner)->Char{
  let old_current=self.current
  self.current+=1
  self.source[old_current]
}

fn Scanner::mattch(self:Scanner,expected:Char)->Bool{
  if self.isAtEnd()||self.source[self.current]!=expected{false}
  else {
    self.current+=1 
    true
  }
}

//before you use peek,you should judge array index by yourself
fn Scanner::peek1(self:Scanner)->Char{
  self.source[self.current]
}

fn Scanner::peek2(self:Scanner)->Char{
  self.source[self.current+1]
}



fn isDigit(c:Char)->Bool{
  c>='0'&&c<='9'
}

fn isAlphaUnderline(c:Char)->Bool{
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')||c=='_';
}

fn isDigitAlphaUnderline(c:Char)->Bool{
  isDigit(c)||isAlphaUnderline(c)
}



fn tokensPrint(tokens:@vec.Vec[Token])->Unit{
  println("Line\tLexeme\tTokenType\tLiteral")
  tokens.iter(
    fn (token){
      print(token.line.to_string()+"\t")
      print(token.lexeme+"\t")
      println(token.t_type.getTokenStr())
    }
  )
}