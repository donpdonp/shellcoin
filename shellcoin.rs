// command line utility for shellcoin
//
use std;
use sqlite;

import core::result::extensions;

fn main() {
  io::println("shellcoin");
  let db_result = sqlite::sqlite_open("usercoins.db");
  if db_result.is_success() {
    let db = db_result.get();
    io::println("db open");
    let exec_result = db.exec("select * from users");
    if exec_result.is_success() {
      let row = exec_result.get();
      io::println(row);
    }
  }
}
