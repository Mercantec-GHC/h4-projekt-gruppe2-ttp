use rand::prelude::*;
use std::env;
use std::fs::File;
use std::io;
use std::io::prelude::*;

#[derive(Debug)]
struct Trivia {
    category: String,
    question: String,
    answer1: String,
    answer2: String,
    answer3: String,
    answer4: String,
    correct_answer: String,
}

fn main() -> io::Result<()> {
    let mut num: i32 = 0;
    let args: Vec<String> = env::args().collect();
    let mut file = File::create("trivia_questions.json")?;
    let questionamount: i32 = args[1].parse::<i32>().unwrap();

    file.write(b"[")?;

    while num != questionamount {
        let result: Trivia = generate_trivia_math();
        write_file(result, &mut file)?;
        num += 1;
        if num != questionamount {
            _ = file.write(b",");
        }
    }
    file.write(b"]")?;
    return Ok(());
}

fn write_file(input: Trivia, file: &mut File) -> io::Result<()> {
    let str = format!(
        r#"
    {{
        "category": "{}",
        "question": "{}",
        "answers": [
        "{}",
        "{}",
        "{}",
        "{}"
        ],
        "correct_answer": "{}"
       
    }}"#,
        input.category,
        input.question,
        input.answer1,
        input.answer2,
        input.answer3,
        input.answer4,
        input.correct_answer
    )
    .into_bytes();
    _ = file.write(&str);
    Ok(())
}

fn generate_trivia_math() -> Trivia {
    let mut rng: ThreadRng = rand::rng();
    let first = rng.random_range(-1000..=1000) as f64;
    let second = rng.random_range(-1000..=1000) as f64;
    let random_offset = rng.random_range(-1000..=1000) as f64;
    let operator: u8 = rng.random_range(1..=4);

    let (symbol, operator): (char, fn(left: f64, right: f64) -> f64) = match operator {
        1 => ('+', |left, right| left + right),
        2 => ('-', |left, right| left - right),
        3 => ('*', |left, right| left * right),
        4 => ('/', |left, right| left / right),
        op => {
            unreachable!("Unknown operator '{op}");
        }
    };
    let result = operator(first, second);

    Trivia {
        category: "Math".to_string(),
        question: format!("{first} {symbol} {second}"),
        answer1: result.to_string(),
        answer2: (result + random_offset).to_string(),
        answer3: (result - random_offset).to_string(),
        answer4: (result - 1.0).to_string(),
        correct_answer: result.to_string(),
    }
}
