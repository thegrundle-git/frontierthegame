extends Node


signal time_changed


var day: int = 1
var hour: int = 8
var minute: int = 0


func add_minutes(amount: int) -> void:
	if amount <= 0:
		return

	minute += amount

	while minute >= 60:
		minute -= 60
		hour += 1

	while hour >= 24:
		hour -= 24
		day += 1

	time_changed.emit()


func get_time_text() -> String:
	return (
		"Day "
		+ str(day)
		+ " — "
		+ _two_digits(hour)
		+ ":"
		+ _two_digits(minute)
	)


func _two_digits(value: int) -> String:
	return str(value).pad_zeros(2)
