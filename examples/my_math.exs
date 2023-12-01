import MyMath

debug_me!(42, 3.33)

add!(42, 3.33)

divide(42, 0)

is_none(:none)

is_none(3.33)

try do
  add!("42", "3.33")
rescue
  e -> IO.puts("#{Exception.format(:error, e)}")
end
