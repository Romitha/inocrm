module InventoriesHelper
	def boolean_in_word boolean_value, true_word, false_word
		if boolean_value
			true_word.html_safe
		else
			false_word.html_safe
		end
	end
end
