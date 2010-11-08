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
		#this is the code to enable pretty validations
		permitted_fields = ['_id', '_revisions', '_rev']
		permit =(field)-> permitted_fields.push(field) if field of newDoc
		
		require =(field, message)-> unless permit(field) and newDoc[field] != ''
										throw(forbidden: message or "Document must have a #{field} field.")
										
		`var __hasProp = Object.prototype.hasOwnProperty;`
		disallow_others =(message)-> for field of newDoc
								unless field in permitted_fields
									throw (forbidden: message or "Attribute '#{field}' is not permitted.") 
		
		integer =(field, message)-> if (field of newDoc) and isNaN(parseInt(newDoc[field]))
										throw (forbidden: message or "'#{field}' must be an integer.") 
									else field
		
		number =(field, message)-> if (field of newDoc) and (typeof(newDoc[field]) != "number" or isNaN(newDoc[field]))
										throw (forbidden: message or "'#{field}' must be a number.") 
									else field
		
		email =(field, message)-> if (field of newDoc) and not newDoc[field].match(/\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
										throw (forbidden: message or "'#{field}' must be a valid email address.") 
									else field
									
		validate_type =(field, type)-> true unless newDoc[field] and typeof(newDoc[field]) != type
		 
		string =(field, message)-> if not validate_type field, 'string'
										throw (forbidden: message or "'#{field}' must be a string.") 
									else field
									
		id_is =(func, field, message)-> func '_id', message
		
		submessage = subkey = ""
		 
		_like =(obj, vald, lax)->
			submessage = ""
			switch typeof(vald)
				when 'function' then 	return vald(obj)
				when 'string'
					submessage = "must be a #{vald} (is #{typeof obj})"
					return typeof obj == vald
				when 'object'
					return false unless typeof obj == 'object'
					if vald instanceof Array
						for val in obj
							unless _like val, vald[0]
								return false
						return true
					for key of obj
						subkey = key
						unless lax or (key of vald)
							return false
						unless _like obj[key], vald[key]	
							return false
					return true
				
		
		like =(name, field, obj)-> #todo this does not check backwards
			return unless newDoc[field]
			subkey = submessage = ''
			unless _like(newDoc[field], obj)
				throw forbidden: "#{field} must be a #{name}. (#{subkey} #{submessage})"
			field		
		
		
		#this is what they look like
		
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