exec = require('child_process').exec;

Utils =
	HandleError: (err, type, args...) ->
		@emit 'error', err, type, args: args	

	GetUid: (userOrGroup = "", type, cb) ->
		if type not in ['u', 'g']
			throw new Error 'Invalid type'
		exec "id -#{type} #{userOrGroup}", (err, stdout, stderr) ->
		    cb err, stdout

module.exports = Utils
