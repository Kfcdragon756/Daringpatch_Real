-- Adjacent color spans become #### after named colors are converted to ##.
-- Consume each delimiter once; the original loop also counted the middle ##.
function MenuComponentManager:add_colors_to_text_object(text_object, ...)
	local text = text_object:text()
	local unchanged_text = text
	local colors = {...}
	local default_color = #colors == 1 and colors[1] or tweak_data.screen_colors.text
	local text_dissected = utf8.characters(text)
	local start_ci, end_ci = {}, {}
	local first_ci = true
	local i = 1

	while i <= #text_dissected do
		if text_dissected[i] == "#" and text_dissected[i + 1] == "#" then
			if first_ci then
				table.insert(start_ci, i)
			else
				table.insert(end_ci, i)
			end
			first_ci = not first_ci
			i = i + 2
		else
			i = i + 1
		end
	end

	if #start_ci == #end_ci then
		for index = 1, #start_ci do
			start_ci[index] = start_ci[index] - ((index - 1) * 4 + 1)
			end_ci[index] = end_ci[index] - (index * 4 - 1)
		end
	end

	text = string.gsub(text, "##", "")
	text_object:set_text(text)
	text_object:clear_range_color(1, utf8.len(text))

	if #start_ci ~= #end_ci then
		Application:error("[MenuComponentManager:color_text_object]: Missing '#' in text:", unchanged_text, #start_ci, #end_ci)
	else
		for index = 1, #start_ci do
			text_object:set_range_color(start_ci[index], end_ci[index], colors[index] or default_color)
		end
	end
end
