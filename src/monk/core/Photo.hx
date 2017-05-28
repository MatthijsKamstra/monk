package monk.core;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import sys.io.FileOutput;

import monk.model.constants.App;

using StringTools;

class Photo {


	public var width(default, default) : Int;
	public var height(default, default) : Int;
	/**
	 *  total path
	 *  @example: bla/bla/bla/photos/foobar/test.jpg
	 */
	public var path(default, default) : String;
	/**
	 *  url without projectFolder
	 *  @example: /photos/foobar/test.jpg
	 */
	public var url(default, default) : String;
	/**
	 *  folders structure without projectFolder and fileName
	 *  @example: '/photos/00_test/'
	 */
	public var folders(default, default) : String;
	/**
	 *  folder without projectFolder and fileName
	 *  @example: '/00_test/'
	 */
	public var folder(default, default) : String;
	/**
	 *  folder without projectFolder and fileName and way to sort folders
	 *  @example: '/test/'
	 */
	public var cleanfolder(default, default) : String;
	/**
	 *  file name without extension
	 */
	public var fileName(default, default) : String;
	/**
	 *  position json for description on photo
	 */
	public var json (default, default) : PositionObj = null;
	/**
	 *  css style for html to position photo description
	 */
	public var style (default, default) : String = '';
	/**
	 *  description html (converted from markdown)
	 */
	public var description (default, default) : String = '';
	/**
	 *  post html (converted from markdown)
	 */
	public var post (default, default) : String = '';



	private var projectFolder : String;
	private var fileExt : String;

	public function new () {
		var args = Sys.args ();
		projectFolder = args[args.length-1];
		// trace(projectFolder);
	}

	public function parse(pathAndFileName:String) {
		this.url = pathAndFileName.replace('${projectFolder}/', '');
		this.path = pathAndFileName;

		var fileOrFolder = url.substring(url.lastIndexOf('/')+1,url.length);

		folders = url.substring(0,url.lastIndexOf('/'));
		folder = folders.replace(App.PHOTOS + '/', '');
		if(folder.indexOf('_')!=-1){
			cleanfolder = folders.split('_')[1];
		} else {
			cleanfolder = folders;
		}

		fileName = fileOrFolder.split('.')[0];
		fileExt = fileOrFolder.split('.')[1];

		getDimensions();
		getJson();
		getDescription();
		getPost();


		// var markdown = super.parse(pathAndFileName);
		// this.createdOn = getPublishDate(pathAndFileName);
		// this.date = getPublishDate(pathAndFileName);
		// this.tags = getTags(markdown);
		// return markdown;
	}

	private function getDimensions(){
		// check dimensions of file
		var p = new Process('identify', ['-format', '%w,%h', this.path ]);
		// var p = new Process('identify', ['-format', '%w,%h', '$projectFolder/${App.EXPORT_FOLDER}/$_folder/$fileOrFolder' ]);
		// read everything from stderr
		var error = p.stderr.readAll().toString();
		// trace("stderr:\n" + error);
		// read everything from stdout
		var stdout = p.stdout.readAll().toString();
		// trace("stdout:\n" + stdout);
		width = Std.parseInt(stdout.split(',')[0]);
		height = Std.parseInt(stdout.split(',')[1]);
		p.close(); // close the process I/O
	}

	private function getJson(){
		var _json = path.replace('.${fileExt}','.json');
		if(FileSystem.exists(_json)){
			json = haxe.Json.parse( sys.io.File.getContent(_json));
			var _top = (Std.is(json.top,String)) ? '${json.top}' : '${json.top}%';
			var _left = (Std.is(json.left,String)) ? '${json.left}' : '${json.left}%';
			var _width = (Std.is(json.width,String)) ? '${json.width}' : '${json.width}%';
			var _height = (Std.is(json.height,String)) ? '${json.height}' : '${json.height}%';
			style = 'style="top: ${_top}; left: ${_left}; width: ${_width}; height: ${_height}"';
		}
	}

	private function getDescription(){
		var _md = path.replace('.${fileExt}','.md');
		if(FileSystem.exists(_md)){
			var markdown = sys.io.File.getContent(_md);
			description = Markdown.markdownToHtml(markdown);
		}
	}

	private function getPost(){
		var _postmd = path.replace('.${fileExt}','_post.md');
		if(FileSystem.exists(_postmd)){
			var markdown = sys.io.File.getContent(_postmd);
			post = Markdown.markdownToHtml(markdown);
		}
	}

}

typedef PositionObj = {
	var top:Int;
	var left:Int;
	var width:Int;
	var height:Int;
	var textcolor:String; //#ffffff
};
