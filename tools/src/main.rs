use rand::prelude::*;
use std::env;
use std::fs::File;
use std::io;
use std::io::prelude::*;
use to_json::ToJson;

mod to_json;

struct Answer {
    correct: bool,
    text: String,
}

impl Answer {
    fn new(correct: bool, text: String) -> Self {
        Self { correct, text }
    }
}

impl ToJson for Answer {
    fn to_json(&self) -> String {
        format!(
            r#"{{ "correct": {}, "text": "{}" }}"#,
            self.correct, self.text
        )
    }
}

struct Trivia {
    category: String,
    question: String,
    answers: [Answer; 4],
}

impl ToJson for Trivia {
    fn to_json(&self) -> String {
        let Trivia {
            category,
            question,
            answers,
        } = self;
        let answers = answers.to_json();
        format!(r#"{{ "category": "{category}", "question": "{question}", "answers": {answers} }}"#,)
    }
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    let question_amount: usize = args[1].parse().unwrap();

    let trivia = (0..question_amount)
        .into_iter()
        .map(|_| generate_trivia_math())
        .collect::<Vec<_>>();
    let mut file = File::create("trivia_questions.json")?;
    file.write_all(trivia.to_json().as_bytes())
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

    let mut answers = [
        Answer::new(true, result.to_string()),
        Answer::new(false, (result + random_offset).to_string()),
        Answer::new(false, (result - random_offset).to_string()),
        Answer::new(false, (result - random_offset / 2.0).to_string()),
    ];

    for _ in 0..100 {
        let idx_1 = rng.random_range(0..answers.len());
        let idx_2 = rng.random_range(0..answers.len());
        answers.swap(idx_1, idx_2);
    }

    Trivia {
        category: "Math".to_string(),
        question: format!("{first} {symbol} {second}"),
        answers,
    }
}
