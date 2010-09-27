_sessid = null
current_user = {}

set_user =(data)->
	if $("User")._id = data
		$get_profile $("User")._id, callback:set_profile
	else
		$("User").fireEvent "no_user"
			
	
set_sessid=(id)->
	$("User").sessid = id
	if id
		Cookie.write _sessid: id
		$get_current_user callback:set_user

set_profile =(data)->
	if data
		$("User").profile = data
		$("User").fireEvent 'profile_update'

	else
		$get_sessid callback:(id)->
			Cookie.write '_sessid', id
			if not $("User")._id
				$get_current_user callback:set_user

if Cookie.read '_sessid'		
	$get_current_user callback:set_user
else
	$get_sessid callback:set_sessid, a:12