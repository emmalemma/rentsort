this.Users =
	_id: "_design/users"
	views:
		by_sessid:
			map: (doc) -> emit(doc.sessid, doc)
	
	validate_doc_update: (newDoc, oldDoc, userCtx)->
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
		
		email =(field, message)-> if (field of newDoc) and not newDoc[field].match(/\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
										throw (forbidden: message or "'#{field}' must be a valid email address.") 
									else field
									
		validate_type =(field, type)-> true unless newDoc[field] and typeof(newDoc[field]) != type
		 
		string =(field, message)-> if not validate_type field, 'string'
										throw (forbidden: message or "'#{field}' must be a string.") 
									else field
									
		id_is =(func, field, message)-> func '_id', message
		
		id_is 	email,  'email', "Invalid email address."
		require integer	'rent', "Enter rent as a whole dollar amount."
		require string 	'work'
		require string 	'home'
		permit 	string 	'sessid'
		
		disallow_others()