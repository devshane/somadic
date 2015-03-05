# Monkey-patches ProgressBar so that it displays periods instead of blank
# spaces.
class ProgressBar
  def render_bar
    return '' if bar_width < 2
    "[" +
      "#" * (ratio * (bar_width - 2)).ceil +
      "." * ((1-ratio) * (bar_width - 2)).floor +
      "]"
  end
end
