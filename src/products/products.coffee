BaseProduct = require './BaseProduct'
utils = require '../utils'

class Wordpress extends BaseProduct
	constructor: (config, vars, subdomain, landingpage, destDir) ->
		super config, vars, subdomain, landingpage, destDir
		@on 'compile.success', =>
			@updateDb()

	updateDb: ->
		conn = @_connect database: @dbname
		conn.execute 'UPDATE wp_options SET option_value = ? WHERE option_name = ?', ["http://#{@fqdn}", 'siteurl'], (err, res) =>
			if err
				utils.HandleError.call @, err, 'updatedb_err'
				return
			conn.execute 'UPDATE wp_options SET option_value = ? WHERE option_name = ?', ["http://#{@fqdn}", 'home'], (err, res) =>
				if err
					utils.HandleError.call @, err, 'updatedb_err'
					return
				conn.end =>
					@emit 'success', @fqdn

class Joomla extends BaseProduct
	constructor: (config, vars, subdomain, landingpage, destDir) ->
		super config, vars, subdomain, landingpage, destDir
		@configFileVars['logDir'] = @_getPath @destDir, 'logs'
		@configFileVars['tmpDir'] = @_getPath @destDir, 'tmp'

class Limesurvey extends BaseProduct

class Moodle extends BaseProduct

class Prestashop extends BaseProduct

class Vtiger extends BaseProduct

class Elgg extends BaseProduct

	constructor: (config, vars, subdomain, landingpage, destdir) ->
		super config, vars, subdomain, landingpage, destdir
		@on 'compile.success', =>
			@updateDb()

	updateDb: ->
		conn = @_connect database: @dbname
		conn.execute 'UPDATE `elgg_datalists` SET `value` = ? WHERE `name` = "path"', ["#{@destDir}/"], (err, res) =>
			if err 
				utils.HandleError.call @, err, 'updatedb_err'
			conn.execute 'UPDATE `elgg_datalists` SET `value` = ? WHERE `name` = "dataroot"', ["#{@baseDir}/elgg_data/"], (err, res) =>
				if err 
					utils.HandleError.call @, err, 'updatedb_err'
				conn.execute 'UPDATE `elgg_sites_entity` SET `url` = ?',[@fqdn], (err, res) =>
					if err 
						utils.HandleError.call @, err, 'updatedb_err'
					conn.execute """
            UPDATE elgg_metastrings set string = ? WHERE id = (SELECT value_id from elgg_metadata where name_id =
            (SELECT * FROM (SELECT id FROM elgg_metastrings WHERE string = 'filestore::dir_root') as ms2) LIMIT 1)
            """, ["#{@baseDir}/elgg_data/"], (err, res) =>
						if err 
							utils.HandleError.call @, err, 'updatedb_err'
						conn.end (err) =>
							if err 
								utils.HandleError.call @, err, 'updatedb_err'
							@emit 'success', @fqdn


module.exports.Wordpress = Wordpress
module.exports.Joomla = Joomla
module.exports.Limesurvey = Limesurvey
module.exports.Moodle = Moodle
module.exports.Prestashop = Prestashop
module.exports.Vtiger = Vtiger
module.exports.Elgg = Elgg
