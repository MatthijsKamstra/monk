package monk.model.constants;

import haxe.macro.Context;

class App {

	/**
	 * 0.0.8	favicon, post default styling (without .json config), possible to define some
	 * 0.0.7	fixed path projects/added info from config file
	 * 0.0.6	ignore img folder when prepare
	 * 0.0.5	parallax js
	 * 0.0.4	bootstrap again
	 * 0.0.3	fix problems with url, clean css,
	 * 0.0.2	added post, meta data, structure, the clever stuff
	 * 0.0.1	initial
	 */
	public static inline var MONK = 'MONK';
	public static inline var VERSION = '0.0.8';

	public static var photoFileSizeArray = [3840, 2560, 1920, 1280, 1024, 640];
	public static var photoFolderArray = ['3840', '2560', '1920', '1280', '1024', '640', 'thumb'];

	public static inline var EXPORT_FOLDER = 'www';
	public static inline var THEME_FOLDER = 'theme';
	public static inline var THEME_FOLDER_DEFAULT = 'theme0';
	public static inline var PHOTOS = 'photos';
	public static inline var PAGES = 'pages';
	public static inline var POSTS = 'posts';
	public static inline var THUMB = 'thumb';
	public static inline var IMG = 'img';

	public static var BUILD : String = getBuildDate();

	macro public static function getBuildDate() {
		var date = Date.now().toString();
		return Context.makeExpr(date, Context.currentPos());
	}

}