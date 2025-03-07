use std::fs::File;
use std::io::prelude::*;
use std::path::Path;
use rand::prelude::*;

fn main() {

}

fn write_file(question) -> Result<(), Error>{
    let mut file = File::create("trivia_questions.json" )?;
    let str = format!(r#"
    {{
        "category": {category},
        "question": {question},
        "answers": [
        {answer1}, 
        {answer2}, 
        {answer3}, 
        {answer4},
        ],
    }}"#).into_bytes();
    file.write_all(&str);
    Ok(())
} 

fn generate_trivia_math() {
    let mut rng = rand::rng();
    let firstnumber: i64 = rng.random();
    let secondnumber: i64 = rng.random();
    let operator = rng.random_range(1..=4);

    
}   