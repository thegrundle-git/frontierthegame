extends PanelContainer
class_name EventChoiceCard


signal choice_requested(option_id: String)


@onready var choose_button: Button = %ChooseButton
@onready var intent_label: Label = %IntentLabel
@onready var reward_label: Label = %RewardLabel
@onready var cost_or_risk_label: Label = %CostOrRiskLabel
@onready var uncertainty_label: Label = %UncertaintyLabel

var _option_id: String = ""


func _ready() -> void:
	choose_button.pressed.connect(_on_choose_pressed)


func configure(option: EventOptionData) -> void:
	if option == null:
		return

	_option_id = option.id
	choose_button.text = option.display_text
	intent_label.text = "Intent: " + _display_or_fallback(
		option.intent_text,
		option.display_text
	)
	reward_label.text = "Likely reward: " + _display_or_fallback(
		option.reward_hint,
		"No material reward expected."
	)
	cost_or_risk_label.text = "Known cost or risk: " + _display_or_fallback(
		option.cost_or_risk_text,
		"None apparent."
	)
	uncertainty_label.text = "Uncertainty: " + _display_or_fallback(
		option.uncertainty_text,
		"None apparent."
	)
	choose_button.tooltip_text = (
		intent_label.text
		+ "\n" + reward_label.text
		+ "\n" + cost_or_risk_label.text
		+ "\n" + uncertainty_label.text
	)


func get_focus_target() -> Control:
	return choose_button


func _on_choose_pressed() -> void:
	if not _option_id.is_empty():
		choice_requested.emit(_option_id)


func _display_or_fallback(value: String, fallback: String) -> String:
	var trimmed: String = value.strip_edges()
	return fallback if trimmed.is_empty() else trimmed
