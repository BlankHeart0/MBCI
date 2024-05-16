fn main {
  let scanner:Scanner = {
    source:@test.expression_t1, 
    start:0, 
    current:0, 
    line:1,
    is_error:false
  }

  println(@test.expression_t1)
  tokensPrint(scanner.scan())
}
