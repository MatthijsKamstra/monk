package monk.model.constants;

import haxe.macro.Context;

class App {

	/**
	 * 0.3.1	fix css for mobile
	 * 0.3.0	generate a dynamic homepage with new stuff all the time, update js for that
	 * 0.2.6	fix img upload folder with .min.jpg files
	 * 0.2.5	glyphicon replaced with fontawesome
	 * 0.2.4	imagemagic convert with better settings for jpg images, and thumbs
	 * 0.2.3	statics navigation bug fixed
	 * 0.2.2	bugfixing nav, top anchor, statics
	 * 0.2.1	static pages
	 * 0.2.0	bootstrap 4, css, javscript updates
	 * 0.1.4	paralax fix for mobile screens (window height to big for resized image)
	 * 0.1.3	gif is also a valid image
	 * 0.1.2	deeplink/anchor
	 * 0.1.1	better generation for subnavigation (posts/pages/photos)
	 * 0.1.0	description fixed, info about photos
	 * 0.0.9	paralax imageheight 0 bug,
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
	public static inline var VERSION = '0.3.1';

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
	public static inline var STATICS = 'statics';
	public static inline var DATA = 'data';

	public static var BUILD : String = getBuildDate();

	macro public static function getBuildDate() {
		var date = Date.now().toString();
		return Context.makeExpr(date, Context.currentPos());
	}

}