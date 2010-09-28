path = require 'path'
@App = 
	paradigm_version: "0.2.0"
	
	port: 			8007
	app_dir:		dir= 			'/Users/admin/Downloads/rentsort'
	private_dir: 	path.join dir, 	'private'
	public_dir: 	path.join dir, 	'public'
	client_cs_dir: 	path.join dir, 	'private/cs/'
	client_js_dir: 	path.join dir, 	'public/js/'
	server_code: 	path.join dir, 	"rentsort.coffee"
	
	db:
		adapter: 	'couchdb'
		host: 		'localhost'
		port: 		5984
		name: 		''
		views: 		path.join dir, 	"views.coffee"
		
	middlewares:
		sessions:
			client: yes
		
		
@Watcher =
	dir:		dir
	verbose: 	no
	process: 	"paradigm"
	args: 		["para"]
	timeout:	300					#seems like a good balance between cpu and response
	ignore: 	[
					'.git'
					/.+\/public\/.+/ #fun little loop here
					/^\..+/			#anything that starts in . probably not necessary
					/\.tmp$/		#same for .tmps
				]
	