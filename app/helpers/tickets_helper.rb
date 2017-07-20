module TicketsHelper
  def convert_hours_minutes(value)
    result_array = []
    a, b = value.to_f.divmod(3600)
    result_array << "Hours: #{a}"

    if b/60 > 1
      result_array << "Minutes: #{b.to_f.divmod(60).first}"
      result_array << "Seconds: #{b.to_i.divmod(60).last}"
    else
      result_array << "Seconds: #{b.to_i}"
    end

    result_array.join(" ")

  end
end
