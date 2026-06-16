module BoardsHelper
  def board_background_style(board)
    if board.background_image.attached?
      "background-image:url('#{url_for(board.background_image)}');background-size:cover;background-position:center"
    elsif board.background_color.to_s.include?("gradient")
      "background:#{board.background_color}"
    elsif board.background_color.present?
      "background-color:#{board.background_color}"
    else
      "background-color:#6366f1"
    end
  end
end
