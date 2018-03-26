package monk.core;

import haxe.crypto.Sha1;

using StringTools;

// base class for Post/Page. Not intended to be used directly.
class Content {

	// Matches all meta-data
	public var metaDataRegex = ~/<!--([\s\S]*?)-->/igm;
	private static var idRegex = ~/meta-id: (\w{40})/im;
	private static var titleRegex = ~/^meta-title:(.*)$/im;

	/**
	 *  Sha1 or value decided in mata-id
	 */
	public var id(default, null) : String;
	/**
	 *  used in navigation and links (set in metadata or filename is used)
	 */
	public var title(default, default) : String;
	/**
	 *  markdown translated to HTML
	 */
	public var content(default, default) : String;
	/**
	 *  filename without extension
	 */
	public var url(default, default) : String;
	/**
	 *  file name with extension
	 */
	public var fileName(default, default) : String;


	private var projectFolder : String;

	public function new() {

		var args = Sys.args ();
		this.projectFolder = args[args.length-1];

		this.content = "";
  	}

	// fileName doesn't include any path characters
	public function parse(pathAndFileName:String) : String {
		var fileName = pathAndFileName.substr(pathAndFileName.lastIndexOf('/') + 1);
		var markdown = sys.io.File.getContent(pathAndFileName);
		this.url = getUrl(fileName);
		this.fileName = fileName;
		this.title = getTitle(fileName, markdown);
		this.content = getHtml(markdown);
		this.id = getAndGenerateId(pathAndFileName);
		return markdown;
  	}

	private static function getUrl(fileName:String) : String {
		return fileName.substr(0, fileName.toUpperCase().lastIndexOf('.'));
	}

	public static function getTitle(fileName:String, markdown:String) : String
	{
		// Check if there's a meta-title defined; use that (first).
		if (titleRegex.match(markdown)) {
			return titleRegex.matched(1).trim(); // first group
		} else {
			var url = getUrl(fileName);

			// var words:Array<String> = url.split('-');

			// var toReturn = "";
			// for (word in words) {
			// 	// TODO: filter out stop-words properly instead of guessing by length
			// 	// Capitalizes the first letter for non-stop-words
			// 	if (word.length > 3) {
			// 		word = word.charAt(0).toUpperCase() + word.substr(1);
			// 	}
			// 	toReturn += word + " ";
			// }

			// return toReturn.trim();
			return url.trim();
		}
	}

	private function getHtml(markdown:String) : String {
		// Remove meta-data lines
		markdown = metaDataRegex.replace(markdown, "");
		var html = Markdown.markdownToHtml(markdown);
		return html;
	}

	// Gets the ID from the file. If there's no ID, inserts and returns the ID.
	private function getAndGenerateId(fileName:String) : String {
		var markdown = sys.io.File.getContent(fileName);
		if (!idRegex.match(markdown)) {
			// Hash the markdown as the id. Any ID will do, really.
			Sys.println('\t> Generated new ID for ${fileName.replace(projectFolder,'')}');
			var id = Sha1.encode(markdown);
			if(metaDataRegex.match(markdown)){
				markdown = markdown.replace('<!--','<!-- \nmeta-id: ${id}\n');
			} else {
				markdown = '<!-- \nmeta-id: ${id}\n-->\n\n${markdown}';
			}
			sys.io.File.saveContent(fileName, markdown);
			return id;
		} else {
			return idRegex.matched(1);
		}
	}
}
