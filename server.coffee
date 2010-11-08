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
			@Models.Users.saveDoc newDoc, (err, doc)=>
												@respond @Session.clear()
		else											
			@respond @Session.clear()

@$matches =()->
	currentUser.bind(@) (err, user)=>
							@respond {error: err} unless user
							@respond {success: true, matches: user.matches}
							
@$findMatches =()->
	currentUser.bind(@) (err, user)=>
							@respond {error: err} unless user
							@respond {error: "No gps data for current user's work."} unless user.work and user.work.gps
							
							sq=(x)->x*x
							distance =(gps1, gps2)-> Math.sqrt(sq(gps1.lat-gps2.lat)+sq(gps1.lng-gps2.lng))
							
							unless user.distance 
								user.distance = distance(user.work.gps, user.home.gps)
								@Models.Users.saveDoc user
								
							@Models.Users.ids (err, doc)=>
								@respond {error: err} unless doc
								
								addMatch =(me, match)=>
									@Models.Users.getDoc me._id, (err, user)=> 
																		return unless user
																		user.matches = [] unless user.matches
																		user.matches.push
																						id: match._id
																						rent: match.rent
																						distance: match.distance
																						home: #we save a slightly different location for safety
																							lat: match.home.gps.lat + Math.random()*.1
																							lng: match.home.gps.lng + Math.random()*.1
																							
																		@Users.saveDoc user, (err, doc) => 
																										if err and err.error == 'conflict'
																											@log "saving failed, retrying"
																											addMatch me, match #if at first you don't succeed...
																										else if err
																											console.log match_err: err
								
								for row in doc.rows
									unless row.id == user._id #we don't want to match ourselves... is that even possible?
										@Models.Users.getDoc row.id, (err, other) =>	
																		return if err
																		return unless other.home and other.home.gps
																		console.log
																					ids:
																						user: user._id
																						other: other._id
																
																		if distance(user.work.gps, other.home.gps) < user.distance
																			if distance(user.home.gps, other.work.gps) < other.distance or other.distance = distance(other.home.gps, other.work.gps)
																				addMatch user, other
																				addMatch other, user
								@respond {success: true}
														
							
	

@$signup =(params)->
	console.log params
	doc =
		sessid: @Session.id
	
	(doc[k] = params[k]) for k of params
	
	sq=(x)->x*x
	distance =(gps1, gps2)-> Math.sqrt(sq(gps1.lat-gps2.lat)+sq(gps1.lng-gps2.lng))
	
	
	
	return @respond {error: "Please provide an email address."} unless doc.email
	delete doc.email
	@Models.Users.saveDoc params.email or no, doc, (err, doc) =>
		if err
			console.log err
			switch err.error
				when "forbidden"	then @respond {error: err.reason}
				when "conflict"		then @respond {error: "That email address is already taken."}
				
		else
			console.log doc
			@respond {success: true}

										
@$getCurrentUser =->
	unless @Session.id 
		return @respond {error: "No session id detected. Do you have cookies enabled?"}
	else
	currentUser.bind(@) (err, user) => 
											if user
												@respond {success: true, user: user}
											else
												console.log(err)
												@respond {error: err}

currentUser =(callback)->
	return callback({error: "no sessid set"}, null) unless @Session and @Session.id 
	@Models.Users.by_sessid {key:@Session.id}, (err, doc)=>
												return callback({error: err}, null) unless doc
												if doc.rows.length > 0
													callback(null, doc.rows[0].value)
												else
													callback({error: "no such user found"}, null)
						
