module ApplicationHelper
  #modify date presentation.
  #
  #example Jan 4th, 2015
  def display_friendly_date(date)
    date.strftime("%b #{date.day.ordinalize}, %Y")
  end
  
  def display_time(datetime)
    datetime.strftime("%H:%M")
  end
  
  def display_friendly_date_and_time(date)
    date.strftime("%b #{date.day.ordinalize}, %Y at %H:%M")
  end
  
  def row_color(status)
    status == 'waiting' ? 'warning' : 'success'
  end
  
  def display_next_baby_sitting_date_info(request)
    " #{display_friendly_date_and_time(request.start)} for #{request.user.full_name}"
  end
  
end