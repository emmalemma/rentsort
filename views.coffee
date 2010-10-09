this.Users =
	_id: "_design/users"
	views:
		by_sessid:
			map: (doc)-> emit(doc.sessid, null)
			
		by_email:
			map: (doc)-> emit(doc.email, null)
	
	validate_doc_update: (newDoc, oldDoc, userCtx)->
		permitted_fields = ['_id', '_revisions']
		permit =(field)-> permitted_fields.push(field) if field of newDoc
		
		require =(field, message)-> unless permit(field) and newDoc[field] != ''
										throw(forbidden: message or "Document must have a #{field} field.")
										
		`var __hasProp = Object.prototype.hasOwnProperty;`
		disallow_others =-> for field of newDoc
								unless field in permitted_fields
									throw (forbidden: message or "Attribute '#{field}' is not permitted.") 
		
		integer =(field, message)-> if (field of newDoc) and isNaN(newDoc[field] = parseInt(newDoc[field]))
										throw (forbidden: message or "'#{field}' must be an integer.") 
									else field
		
		email =(field, message)-> if (field of newDoc) and not newDoc[field].match(/\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
										throw (forbidden: message or "'#{field}' must be a valid email address.") 
									else field
									
		validate_type =(field, type)-> (field of newDoc) and typeof newDoc[field] == type
		
		string =(field, message)-> unless validate_type field, 'string'
										throw (forbidden: message or "'#{field}' must be a string.") 
									else field
									
		id_is =(func, field, message)-> 
										func '_id', message
										delete newDoc[field]
		
		id_is 	email,  'email', "Invalid email address."
		require integer	'rent'
		require string 	'work'
		require string 	'home'
		permit 	string 	'sessid'
		disallow_others()