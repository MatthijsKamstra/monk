package monk.core;

import monk.model.constants.App;

class Config {

	// config file and default values used for generation
	public var monkConfig : ConfigObj;

	public var monkTitle : String = '${App.MONK}';
	public var monkSiteUrl : String = 'http://www.matthijskamstra.nl'; 	// default, maybe default the Monk website
	public var monkTheme : String = 'theme0';							// default theme, all folders should start with "theme"
	public var monkBackgroundcolor : String = '#000000';				// default background color: hex value for black
	public var monkGenerator : String = '${App.MONK}-${App.VERSION}';	// self promotion!
	public var monkIsSocial : Bool = false;								// no idea why I want this
	public var googleAnalytics : String = 'UA-XXXXXXX-X'; 				// obviousily fake!

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
			config.monkGenerator = '${App.MONK} ${App.VERSION}';
			config.googleAnalytics = config.monkConfig.googleAnalytics;
			config.monkSiteUrl = config.monkConfig.site_url;

			// [mck] make it possible to use *any* value in the config
			var structsFields:Array<String> = Reflect.fields(config.monkConfig);
			var classFields:Array<String> = Type.getInstanceFields(Type.getClass(config));

			for (field in structsFields)
			{
				if (classFields.indexOf(field) > -1)
				{
					var value:Dynamic = Reflect.field(config.monkConfig, field);
					Reflect.setField(config, field, value);
				}
			}

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
	var site_url:String; 					// needed for social sharing...
	var theme_dir:String;
	var backgroundcolor:String; 			// #ffffff
	@:optional var social_button:Bool;
	@:optional var googleAnalytics:String;
}