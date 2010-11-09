this.Users =
	_id: "_design/users"
	views:
		by_sessid:
			map: (doc) -> emit(doc.sessid, doc)
			
		all:
			map: (doc) -> emit(null, doc)
			
		by_rent:
			map: (doc) -> emit(doc.rent, null)
		
		ids:
			map: (doc) -> emit(null,null)
	
	validate_doc_update: (newDoc, oldDoc, userCtx)->		
		is_location =(field)-> _like field,
											display: 'string'
											query: 	 'string'
											gps:
												lat: 'number'
												lng: 'number'
		
		location =(field)-> like 'location', field, is_location
		
		matches =(field)-> like 'matches', field,  [
													id: 'string'
													rent: 'number'
													distance: 'number'
													home:
														lat: 'number'
														lng: 'number'
													]
													
		id_is 	email,   'email', "Invalid email address."
		require number	 'rent', "Enter rent as a whole dollar amount."
		require location 'work'
		require location 'home'
		permit  number 	 'distance'
		permit 	string 	 'sessid'
		permit  matches  'matches'
		
		disallow_others()