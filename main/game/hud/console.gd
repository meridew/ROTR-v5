extends CanvasLayer

var commands = ConsoleCommands.new()

@onready var input = $Panel/VBoxContainer/input
@onready var output = $Panel/VBoxContainer/output

var command_history = []
var current_command = -1

func _ready():
	self.hide()
	output.bbcode_enabled = true

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		if self.is_visible():
			self.hide()
			input.release_focus()
			GameStateManager.console_open = false
			GameStateManager.resume()
		else:
			self.show()
			input.grab_focus()
			GameStateManager.console_open = true
			GameStateManager.pause()
		return true

	if self.is_visible:
		if Input.is_action_just_pressed("ui_up"):
			if current_command > 0:
				current_command -= 1
				input.text = command_history[current_command]
				input.set_caret_column(input.text.length())  # Set cursor to the end of the line
		if Input.is_action_just_pressed("ui_down"):
			if current_command < command_history.size() - 1:  # Changed this condition
				current_command += 1
				input.text = command_history[current_command]
				input.set_caret_column(input.text.length())  # Set cursor to the end of the line
			elif current_command == command_history.size() - 1:  # Clear the input if we're at the end of the history
				current_command += 1
				input.clear()

func execute_command(command_string):
	var command_list = command_string.split(" ")
	var command = command_list[0]
	var args = command_list.slice(1, command_list.size())
	
	if commands.has_method(command):
		var result = commands.callv(command, args)
		if result:
			output.append_text(result)
	else:
		output.append_text("[color=darkred]Unknown command: " + command + "[/color]" + "\n")

func _on_input_text_submitted(text):
	output.add_text("> " + text + "\n")
	execute_command(text)
	input.clear()
	command_history.append(text)
	current_command = command_history.size()  # Set the current command to the end of the list
