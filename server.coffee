#functions executed on server go here
 
@$logout =->
	@Users.by_sessid {key:@Session.id}, (err, doc)=>
		console.log "logging out..."
		console.log err
		console.log doc
		if doc and doc.rows.length > 0
			newDoc = doc.rows[0].value
			delete newDoc.sessid
			console.log newDoc
			@Users.saveDoc newDoc, (err, doc)=>
												console.log "saving..."
												console.log err
												console.log doc
												@respond @Session.clear()
		else											
			@respond @Session.clear()

@$signup =(params)->
	doc =
		sessid: @Session.id
	
	(doc[k] = params[k]) for k of params
	console.log doc
	
	return @respond {error: "Please provide an email address."} unless doc.email
	delete doc.email
	@Users.saveDoc params.email or no, doc, (err, doc) =>
		if err
			#console.log err
			switch err.error
				when "forbidden"	then @respond {error: err.reason}
				when "conflict"		then @respond {error: "That email address is already taken."}
				
		else
			console.log doc
			@respond {success: true}

										
@$getCurrentUser =->
	return @respond {error: "No session id detected. Do you have cookies enabled?"} unless @Session.id 
	@Users.by_sessid {key:@Session.id}, (err, doc)=>												# 
													# console.log "Searching for user."
													# console.log err
													# console.log doc
												if doc 
													if doc.rows.length > 0
														@respond {success: true, user: doc.rows[0].value}
													else
														@respond {error: "No user found. Please log in."}
												else
													@respond {error: err}
						
@$validate_user_email =(email_string)->
	if not ematch = email_string.match(/\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
		return @respond {flash:"Invalid email address."}
	email = ematch[0]
	@Users.getDoc email, (err, email_doc) =>
		if err
			@respond {flash:"Ok!"}
		else
			@respond {flash:"That email is already taken."}
			
@$save_new_user =(params)->
	doc =
		_id: params.email
		sessid: @_sessid
	
	for key in params
		if key in ['facts']
			doc[key] = params[key]
			
	@Users.saveDoc params.email, doc, (err, email_doc) =>
		if err
			console.log err
			@respond {"error": "That email is already taken."}
		else
			@respond {"success": "Account registered."}
