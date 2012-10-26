class DateTime
  def as_json(options = nil)
    strftime("%b %d, %Y")
  end
end
