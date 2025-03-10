pub trait ToJson {
    fn to_json(&self) -> String;
}

impl<T, const N: usize> ToJson for [T; N]
where
    T: ToJson,
{
    fn to_json(&self) -> String {
        let items = self
            .iter()
            .map(|v| v.to_json())
            .collect::<Vec<_>>()
            .join(",");

        format!("[{items}]")
    }
}

impl<T> ToJson for Vec<T>
where
    T: ToJson,
{
    fn to_json(&self) -> String {
        let items = self
            .iter()
            .map(|v| v.to_json())
            .collect::<Vec<_>>()
            .join(",");

        format!("[{items}]")
    }
}
