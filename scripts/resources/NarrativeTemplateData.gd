extends Resource
class_name NarrativeTemplateData


@export var category: String = ""
@export var selector_id: String = "default"
@export_multiline var variants: Array[String] = []


func render_variant(
	variant: String,
	context: Dictionary
) -> String:
	var rendered := variant

	for key_variant: Variant in context:
		var key := str(key_variant)
		rendered = rendered.replace(
			"{" + key + "}",
			str(context[key_variant])
		)

	return rendered
