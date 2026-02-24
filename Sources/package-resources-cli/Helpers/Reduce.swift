func reduce<Value>(
	_ value: Value,
	with transform: (inout Value) -> Void
) -> Value {
	var _value = value
	transform(&_value)
	return _value
}
