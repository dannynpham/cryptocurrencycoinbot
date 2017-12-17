module Controller
  def valid_params?
    params[:text].is_a?(String) && params[:trigger_word].is_a?(String)
  end

  def respond_message message
    content_type :json
    {:text => message}.to_json
  end
end

helpers Controller
