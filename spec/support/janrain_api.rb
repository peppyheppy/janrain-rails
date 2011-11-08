class JanrainAPI
  def call(env)
    request = Rack::Request.new env
    case request.url
    when ""
      [401, {"Content-Type" => "application/atom+xml"}, ['<html/>']]
    else
      debugger
      puts
    end
  end
end
