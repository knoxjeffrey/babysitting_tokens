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
  
  def row_color(status)
    status == 'waiting' ? 'warning' : 'success'
  end
end
