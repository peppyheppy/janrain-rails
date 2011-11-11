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
    when /\/entity/
      case env['HTTP_AUTHORIZATION']
      when 'OAuth a_valid_token' # (ok)
        [200, {"Content-Type" => "application/json"}, ['{"result":{"aboutMe":null,"birthday":null,"created":"2011-11-05 19:00:08.339082 +0000","currentLocation":null,"display":null,"displayName":"Paul Hepworth","email":"paul.hepworth@peppyheppy.com","emailVerified":"2011-11-05 19:00:10 +0000","familyName":null,"gender":"","givenName":null,"id":7,"lastLogin":"2011-11-05 19:59:07 +0000","lastUpdated":"2011-11-05 19:59:08.054143 +0000","middleName":null,"password":null,"photos":[],"primaryAddress":{"address1":null,"address2":null,"city":null,"company":null,"mobile":null,"phone":null,"stateAbbreviation":null,"zip":null,"zipPlus4":null},"profiles":[{"accessCredentials":"","domain":"google.com","friends":[],"id":8,"identifier":"https://www.google.com/profiles/1056740970740279255","profile":{"aboutMe":null,"accounts":[],"addresses":[],"anniversary":null,"birthday":null,"bodyType":{"build":null,"color":null,"eyeColor":null,"hairColor":null,"height":null},"books":[],"cars":[],"children":[],"currentLocation":{"country":null,"extendedAddress":null,"formatted":null,"latitude":null,"locality":null,"longitude":null,"poBox":null,"postalCode":null,"region":null,"streetAddress":null,"type":null},"displayName":null,"drinker":null,"emails":[{"id":32,"primary":null,"type":"other","value":"paul.hepworth@peppyheppy.com"}],"ethnicity":null,"fashion":null,"food":[],"gender":null,"happiestWhen":null,"heroes":[],"humor":null,"ims":[],"interestedInMeeting":null,"interests":[],"jobInterests":[],"languages":[],"languagesSpoken":[{"id":31,"languageSpoken":"en-US"}],"livingArrangement":null,"lookingFor":[],"movies":[],"music":[],"name":{"familyName":"Hepworth","formatted":"Paul Hepworth","givenName":"Paul","honorificPrefix":null,"honorificSuffix":null,"middleName":null},"nickname":null,"note":null,"organizations":[],"pets":[],"phoneNumbers":[],"photos":[],"politicalViews":null,"preferredUsername":"paul","profileSong":null,"profileUrl":null,"profileVideo":null,"published":null,"quotes":[],"relationshipStatus":null,"relationships":[],"religion":null,"romance":null,"scaredOf":null,"sexualOrientation":null,"smoker":null,"sports":[],"status":null,"tags":[],"turnOffs":[],"turnOns":[],"tvShows":[],"updated":null,"urls":[{"id":30,"primary":null,"type":"other","value":"https://www.google.com/profiles/88998394657984365"}],"utcOffset":null},"provider":null,"remote_key":""}],"statuses":[],"uuid":"6f498a67a-064e-4d8b-8e90-92594f20f206"},"stat":"ok"}']]
      when 'OAuth an_invalid_token' # (error)
        [200, {"Content-Type" => "application/json"}, ['{"code":414,"error":"access_token_expired","error_description":"access_token expired","stat":"error"}']]
      else
        puts "*" * 40
        puts "/entity"
        puts env['HTTP_AUTHORIZATION']
        puts request.url
        puts "*" * 40
      end
    else
      puts "*" * 40
      puts request.url
      puts "*" * 40
    end
  end
end
