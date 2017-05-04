package monk.core;

import monk.model.constants.App;

class Config {

	// config file and default values used for generation
	public var monkConfig : ConfigObj;
	public var monkTitle : String = '${App.MONK}';
	public var monkIsSocial : Bool = false;
	public var monkBackgroundcolor : String = '#000000';
	public var monkTheme : String = 'theme0';

	public function new () {
		// trace('Config');
	}

	public static function init(path:String):Config
	{
		var config  = new Config();

		// trace( 'path: ' + path );
		// trace(config);

		if (!sys.FileSystem.exists(path)) {
			Sys.println ('[ERROR] Config file is missing. Please add it as a JSON file.');
			return config;
		} else {
			config.monkConfig = haxe.Json.parse( sys.io.File.getContent( path ) );
			config.monkTitle = config.monkConfig.site_title;
			config.monkIsSocial = config.monkConfig.social_button;
			config.monkBackgroundcolor = config.monkConfig.backgroundcolor;
			config.monkTheme = config.monkConfig.theme_dir;
			config.validate();
			return config;
		}
	}

	public function validate()
	{
    // if (this.siteName.isNullOrWhitespace())
    // {
    //     throw 'siteName is a required config field, and it is empty';
    // }
    // if (this.siteUrl.isNullOrWhitespace())
    // {
    //     throw 'siteUrl is a required config field, and it is empty';
    // }
    // if (this.authorName.isNullOrWhitespace())
    // {
    //     throw 'authorName is a required config field, and it is empty';
    // }
  }

}


typedef ConfigObj = {
	var site_title:String;
	var theme_dir:String;
	var backgroundcolor:String; //#ffffff
	@:optional var social_button:Bool;
}