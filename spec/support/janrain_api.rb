class JanrainAPI
  def call(env)
    request = Rack::Request.new env
    case request.url
    # /oath/token (error)
    when /\/oauth\/token.*code=an_invalid_code/
      [200, {"Content-Type" => "application/json"}, ['{"argument_name":"authorization_code","code":200,"error":"invalid_grant","error_description":"authorization_code is not valid","stat":"error","sub_error":"invalid_argument"}']]
    # /oath/token (ok)
    when /\/oauth\/token.*code=a_valid_code/
      [200, {"Content-Type" => "application/json"}, ['{"access_token":"a_valid_token","expires_in":3600,"refresh_token":"ajwym5c4f3c3bj6w92sb","stat":"ok","transaction_state":{"capture":{"action":"token_url_2","session_expires":null},"engage":{"identifier":"https://www.google.com/profiles/104030799970740279255","providerName":"Google"}}}']]
    # /entity | with auth_token header
    when /\/entity.find.*newuser%40(in)?valid.*/
      [200, {"Content-Type" => "application/json"}, ['{"result_count":0,"results":[],"stat":"ok"}']]
    when /\/entity.find.*existinguser%40(in)?valid.*/
      [200, {"Content-Type" => "application/json"}, ['{"result_count":1,"results":[{"bio":null,"birthDate":"1900-01-01","birthday":null,"country":null,"created":"2011-12-29 19:27:11.436142 +0000","display":null,"displayName":null,"email":"existinguser@valid.com","firstName":null,"gender":"male","id":308099,"permissions":4,"flags":0,"upperGenreBounds":null,"uuid":"995d75c2-1118-4b6e-bd63-b46d735346c4"}],"stat":"ok"}']]
    when /\/entity.find.*/ # this is for allowing all user.save/update's to be successful, etc
      [200, {"Content-Type" => "application/json"}, ['{"result_count":1,"results":[{"bio":null,"birthDate":"1900-01-01","birthday":null,"country":null,"created":"2011-12-29 19:27:11.436142 +0000","display":null,"displayName":null,"email":"existinguser@valid.com","firstName":null,"gender":"male","id":308099,"permissions":4,"flags":0,"upperGenreBounds":null,"uuid":"995d75c2-1118-4b6e-bd63-b46d735346c4"}],"stat":"ok"}']]
    when /\/entity.update.*existinguser%40valid.*/
      [200, {"Content-Type" => "application/json"}, ['{"stat":"ok"}']]
    when /\/entity.update.*existinguser%40invalid.*/ #
      [200, {"Content-Type" => "application/json"}, ['{"attribute_name":"/firstNames","code":223,"error":"unknown_attribute","error_description":"attribute does not exist: /firstNames","stat":"error"}']]
    when /\/entity.update.*/ # this is for allowing all user.save/update's to be successful, etc
      [200, {"Content-Type" => "application/json"}, ['{"stat":"ok"}']]
    when /\/entity.create.*newuser%40valid.*/
      [200, {"Content-Type" => "application/json"}, ['{"id":978,"stat":"ok","uuid":"300d7ad1-b280-44bc-8441-da140ef6a506"}']]
    when /\/entity.create.*newuser%40invalid.*/ #
      [200, {"Content-Type" => "application/json"}, ['{"attribute_name":"/emailer","code":223,"error":"unknown_attribute","error_description":"attribute does not exist: /emailer","stat":"error"}']]
    when /\/entity$/
      case env['HTTP_AUTHORIZATION']
      when 'OAuth a_valid_token' # (ok)
        [200, {"Content-Type" => "application/json"}, ['{"result":{"aboutMe":null,"birthday":null,"created":"2011-11-05 19:00:08.339082 +0000","currentLocation":null,"display":null,"displayName":"Paul Hepworth","email":"paul.hepworth@peppyheppy.com","emailVerified":"2011-11-05 19:00:10 +0000","familyName":null,"gender":"","givenName":null,"id":7,"lastLogin":"2011-11-05 19:59:07 +0000","lastUpdated":"2011-11-05 19:59:08.054143 +0000","middleName":null,"password":null,"photos":[],"primaryAddress":{"address1":null,"address2":null,"city":null,"company":null,"mobile":null,"phone":null,"stateAbbreviation":null,"zip":null,"zipPlus4":null},"profiles":[{"accessCredentials":"","domain":"google.com","friends":[],"id":8,"identifier":"https://www.google.com/profiles/1056740970740279255","profile":{"aboutMe":null,"accounts":[],"addresses":[],"anniversary":null,"birthday":null,"bodyType":{"build":null,"color":null,"eyeColor":null,"hairColor":null,"height":null},"books":[],"cars":[],"children":[],"currentLocation":{"country":null,"extendedAddress":null,"formatted":null,"latitude":null,"locality":null,"longitude":null,"poBox":null,"postalCode":null,"region":null,"streetAddress":null,"type":null},"displayName":null,"drinker":null,"emails":[{"id":32,"primary":null,"type":"other","value":"paul.hepworth@peppyheppy.com"}],"ethnicity":null,"fashion":null,"food":[],"gender":null,"happiestWhen":null,"heroes":[],"humor":null,"ims":[],"interestedInMeeting":null,"interests":[],"jobInterests":[],"languages":[],"languagesSpoken":[{"id":31,"languageSpoken":"en-US"}],"livingArrangement":null,"lookingFor":[],"movies":[],"music":[],"name":{"familyName":"Hepworth","formatted":"Paul Hepworth","givenName":"Paul","honorificPrefix":null,"honorificSuffix":null,"middleName":null},"nickname":null,"note":null,"organizations":[],"pets":[],"phoneNumbers":[],"photos":[],"politicalViews":null,"preferredUsername":"paul","profileSong":null,"profileUrl":null,"profileVideo":null,"published":null,"quotes":[],"relationshipStatus":null,"relationships":[],"religion":null,"romance":null,"scaredOf":null,"sexualOrientation":null,"smoker":null,"sports":[],"status":null,"tags":[],"turnOffs":[],"turnOns":[],"tvShows":[],"updated":null,"urls":[{"id":30,"primary":null,"type":"other","value":"https://www.google.com/profiles/88998394657984365"}],"utcOffset":null},"provider":null,"remote_key":""}],"statuses":[],"uuid":"6f498a67a-064e-4d8b-8e90-92594f20f206"},"stat":"ok"}']]
      when 'OAuth an_invalid_token' # (error)
        [200, {"Content-Type" => "application/json"}, ['{"code":414,"error":"access_token_expired","error_description":"access_token expired","stat":"error"}']]
      else
        unexpected_http_request(request, ["/entity", env['HTTP_AUTHORIZATION']])
      end
    else
      unexpected_http_request(request)
    end
  end

  private

  def unexpected_http_request(request, notes=[])
    $stdout.puts "-" * 40
    $stdout.puts request.url
    $stdout.puts "-" * 40
    notes.each do |note|
      $stdout.puts note.to_s
    end
    $stdout.puts "-" * 40
  end
end
