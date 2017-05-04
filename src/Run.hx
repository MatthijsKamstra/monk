package;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import sys.io.FileOutput;

import monk.core.Config;
import monk.core.Page;
import monk.core.Post;
import monk.core.Photo;
import monk.generate.*;
import monk.model.constants.App;

using StringTools;
using DateTools;

class Run {

	var projectFolder : Dynamic;
	var args : Array<String>  = Sys.args ();
	var current = Sys.getCwd ();

	var fileExtArr = ['jpg', 'jpeg', 'png'];
	// var fileSizeArr = [3840, 2560, 1920, 1280, 1024, 640];

	var config : Config;
	var dateFormat : String = 'dd-mm-YYYY';

	var isFirst : Bool = true; // check only once
	var isJpegOptim : Bool = false;
	var isOverWrite : Bool = false;

	public function new () {
		Sys.println('${App.MONK} - ${App.VERSION}');

		args = Sys.args ();
		projectFolder = args[args.length-1];

		isJpegOptim = (args.indexOf('-optim')!= -1);
		isOverWrite = (args.indexOf('-force')!= -1);

		for ( i in 0 ... args.length-1) {
			var arg = args[i];
			switch (arg.toString()) {
				case '-force':
					isOverWrite = true;
				case '-optim':
					isJpegOptim = true;
				case 'clear':
					trace('clear www');
					FileSystem.deleteDirectory('${projectFolder}/${App.EXPORT_FOLDER}');
				case 'test':
					initTest();
				case 'scaffold', 'scafold', 'skafold', 'skaffold':
					initScaffold();
				case 'prepare':
					// trace ('prepare');
					imagePrepare(projectFolder);
				case 'generate':
					initGenerate();
				default :
					showHelp();
			}
		}
	}


	// ____________________________________ init function ____________________________________

	function initGenerate(){
		Sys.println (':: ${App.MONK} :: generate');

		// [mck] load existing config
		config = Config.init('${projectFolder}/config.json');

		// copy files from "theme" the same folder in "www" / export folder
		copyFiles('${projectFolder}/${config.monkTheme}', ['css','js']);

		// Start creating content files
		var pages:Array<Page> = getPages(projectFolder);
		var posts:Array<Post> = getPosts(projectFolder);
		var photos:Array<Photo> = getPhotos(projectFolder);
		// var tags:Array<String> = Post.getPostTags(posts);
		// FileSystem.copyDirectoryRecursively('${srcDir}/content', '${binDir}/content');

		// Start HTML generation
		// var layoutHtml = getAndValidateLayoutHtml(srcDir, config, posts, pages);
		// generateHtmlPages(posts, pages, tags, layoutHtml, srcDir, binDir, config);
		generateHtmlPages(posts, pages, photos);
		// generateRssFeed(posts, binDir, config);

		// trace('Generated index page, ${pages.length} page(s), and ${posts.length} post(s).');

	}

	function initScaffold(){
		Sys.println (':: ${App.MONK} :: scaffold');

		if(!FileSystem.exists('${projectFolder}')) return;

		// [mck] load existing config / or use default values
		config = Config.init('${projectFolder}/config.json');

		// create export files
		createDir(App.EXPORT_FOLDER);
		createFavicon();
		setupPostAndPages();
		setupPhoto();
		setupTheme('${App.THEME_FOLDER_DEFAULT}');
		setupConfig('config.json');

		// read rest folders
		var _arr = FileSystem.readDirectory('${projectFolder}');
		for ( i in 0 ... _arr.length ) {

			var fileName = _arr[i];

			if(fileName.startsWith(".")) continue; // ignore invisible (OSX) files like ".DS_Store"
			if(fileName.startsWith('_')) continue; // ignore files starting with "_"

			// [mck] ignore these files/folders
			if(fileName == App.EXPORT_FOLDER) continue;					// ignore www (export) folder
			if(fileName == 'config.json') continue;			// ignore config.json
			if(fileName.startsWith('theme')) continue;		// ignore any folder that starts with "theme"

			// [mck] only check folders
			if(FileSystem.isDirectory('${projectFolder}$fileName')){
				imagePrepare('${projectFolder}$fileName');
			}
		}
	}

	function initTest ()  {
		// trace('initTest: ${projectFolder}');
		// trace(Sys.command('ls'));

		var arr = ignoreFilesOrFolders(['foobar.jpg', 'foobar.json', 'foobar.md', 'foobar.png', 'foobar.gif'], ['md','json']);
		trace('test arr: ' + arr);

		// var temp = Sys.command('convert',[
		// 	"-resize", "200x200",
		// 	"-define", "filter:blur=5",
		// 	'${projectFolder}/pattern.jpg', '${projectFolder}/test/_pattern.png'
		// ]);
		// trace(temp);
		// convert -resize 100x80 -define filter:blur=2  pattern.jpg test/_pattern.png
	}

	function imagePrepare(folder:String){
		Sys.println('\t+ prepare -> ${folder.replace(projectFolder,'')}');

		var arr = FileSystem.readDirectory(folder);
		for ( i in 0 ... arr.length ) {
			var fileOrFolder = arr[i];
			if(FileSystem.isDirectory('$folder/$fileOrFolder')){
				if(fileOrFolder.startsWith('_')) continue;
				if(fileOrFolder.startsWith('.')) continue;
				imagePrepare('$folder/$fileOrFolder');
			} else {
				var fileName = fileOrFolder.split('.')[0];
				var fileExt = fileOrFolder.split('.')[1].toLowerCase();

				if(fileName.startsWith('_')) continue;
				if(fileName.startsWith('.')) continue;

				if(fileExtArr.indexOf(fileExt) != -1){
					createFile('${folder}', '${fileName}.md', '# ${fileName}\n\nText over photo');
					createFile('${folder}', '${fileName}_post.md', '# ${fileName}\n\nMore indepth info about this image');

					var obj = {
						"top": Std.random(5)*10,
						"left": Std.random(5)*10,
						"width": Std.random(5)*10,
						"height": Std.random(5)*10,
						"textcolor": "#ffffff"
					}
					createFile('${folder}', '${fileName}.json', haxe.Json.stringify(obj));
				}
			}
		}
	}

	// ____________________________________ setup ____________________________________

	function setupPhoto(){
		createDir(App.PHOTOS);
		createDir('${App.PHOTOS}/monk');
		// createDir('$PHOTO/haxe');
		createDir('${App.PHOTOS}/_ignorefolder');

		createDummyImage('${App.PHOTOS}/monk','white image','white');
		createDummyImage('${App.PHOTOS}/monk','orange image','orange', 'OrangeRed');
		createDummyImage('${App.PHOTOS}/monk','ignore image','_ignore', 'Plum');
	}

	function setupPostAndPages(){
		createDir(App.POSTS);
		createDir(App.PAGES);

		createFile(App.PAGES, 'about.md' , haxe.Resource.getString('about'));
		createFile(App.PAGES, 'contact.md' , haxe.Resource.getString('contact'));
		createFile(App.PAGES, '_ignorepage.md' , '# This page will be ignored\n\nSo write what you want!');

		createFile(App.POSTS, '_ignorepost.md' , '# This post will be ignored\n\nSo write what you want!');
		createFile(App.POSTS, '00post.md' , haxe.Resource.getString('post0'));
		createFile(App.POSTS, '01post.md' , haxe.Resource.getString('post1'));
	}

	function setupTheme(name:String){
		createDir('${name}');
		createDir('${name}/img');

		createFile('${name}', 'monk.css', haxe.Resource.getString('css'));
		createFile('${name}', 'monk.js', haxe.Resource.getString('js'));
		createFile('${name}', 'index.html', haxe.Resource.getString('indexTemplate'));
		createFile('${name}', 'index-post.html', '');
		createFile('${name}', 'post.html', haxe.Resource.getString('postTemplate'));
		createFile('${name}', 'page.html', haxe.Resource.getString('pagesTemplate'));
	}

	function setupConfig(name:String){
		var obj : ConfigObj = {
			"site_title" : config.monkTitle,
			"theme_dir" : config.monkTheme,
			"social_button": config.monkIsSocial,
			"backgroundcolor" : config.monkBackgroundcolor
		}
		createFile('', name, haxe.Json.stringify(obj));
	}

	// ____________________________________ generate ____________________________________

	function generateHtmlPages(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>) {
		generateHtmlFilesForPages(pages);
		generateHtmlFilesForPosts(posts, pages);
		generatePhotos(photos, pages);
	}

	private function generateHtmlFilesForPages(pages:Array<Page>) {
		// var template = haxe.Resource.getString('pagesTemplate');
		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/page.html' );
		for (page in pages) {
			var nav = '';
			for(p in pages){
				var klass = '';
				if(page.title == p.title) klass = ' class="active"';
				nav += '<li${klass}><a href="${p.url}.html">${p.title}</a></li>';
			}
			var obj = {
				 content : page.content,
				 navigation: nav,
				 title: page.title
			}
			createWithGenTemplate(App.EXPORT_FOLDER, '${page.url}.html', template, obj);
		}
	}

	private function generateHtmlFilesForPosts(posts:Array<Post>,pages:Array<Page>) {
		createDir('${App.EXPORT_FOLDER}/${App.POSTS}');
		// var str = haxe.Resource.getString('postTemplate');
		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/post.html' );
		for (post in posts) {
			var nav = '';
			for(p in pages){
				var klass = '';
				nav += '<li${klass}><a href="${p.url}.html">${p.title}</a></li>';
			}
			var obj = {
				 content : post.content,
				 navigation: nav,
				 title: post.title
			}
			createWithGenTemplate('${App.EXPORT_FOLDER}/${App.POSTS}', '${post.url}.html', template, obj);
		}
	}

	private function generatePhotos(photos:Array<Photo>,pages:Array<Page>){
		createDir('${App.EXPORT_FOLDER}/${App.PHOTOS}');

		// var str = haxe.Resource.getString('indexTemplate');
		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/index.html' );


		var tempSubArr = [];

		var nav_pages = '';
		for(p in pages){
			var klass = '';
			nav_pages += '<li${klass}><a href="${p.url}.html">${p.title}</a></li>';
		}

		// create photo folders
		for (photo in photos){

			if(tempSubArr.indexOf(photo.folders) == -1) tempSubArr.push(photo.folders);

			// create directories
			createDir('${App.EXPORT_FOLDER}/${photo.folders}');
			// copy original file to this folder
			File.copy(photo.path, '${projectFolder}/${App.EXPORT_FOLDER}/${photo.url}');
			// generate all photo size folders + thumb folder
			for ( exportfolder in App.photoFolderArray ) {
				createDir('${App.EXPORT_FOLDER}/${photo.folders}/${exportfolder}');
				if(exportfolder == App.THUMB){
					generateThumb(photo);
				} else {
					generatePhotoSizes(photo);
				}
			}
			FileSystem.deleteFile('${projectFolder}/${App.EXPORT_FOLDER}/${photo.url}');
		}



		// trace(tempSubArr.length);

		for(folder in tempSubArr){
			var html = '';
			for (photo in photos){
				// trace(photo.folders, folder, photo.fileName);
				if (photo.folders == folder){
					var thumb = '${photo.folders}/${App.THUMB}/${photo.fileName}.jpg';
					html += '
						<div class="slide" data-width="${photo.width}" data-height="${photo.height}" style="background-image: url($thumb);background-repeat: no-repeat;background-size: cover;">
							<a name="1" class="internal"></a>
							<div class="post" ${photo.style}>
								<div class="content">
									${photo.description}
								</div>
							</div>
							<img src="${thumb}" class="full" data-folder="${photo.folders}" data-img="${photo.fileName}.jpg" width="${photo.width}" height="${photo.height}">
						</div>
					'.replace('\t','').replace('\n',''); // strip tabs and returns


				}
			}
			var nav_photo = '';
			for(folder in tempSubArr){
				var klass = '';
				// if(page.title == p.title) klass = ' class="active"';
				var temp = '';
				nav_photo += '<li${klass}><a href="${folder}/index.html">${folder.split('/')[1]}</a></li>';
			}

			if(isFirst){
				var templateObj = {
					title : 'foo',
					page_navigation : nav_pages,
					post_navigation : '<!-- post_navigation -->',
					photo_navigation : nav_photo,
					content: html
				};
				createWithGenTemplate(App.EXPORT_FOLDER, 'index.html', template, templateObj);
				isFirst = false;
			}

			html = html.replace('${folder}/','');
			// nav_pages = nav_pages.replace('${folder}/','');
			nav_photo = nav_photo.replace('${App.PHOTOS}/','../../${App.PHOTOS}/');
			var templateObj = {
				title : 'foo',
				page_navigation : nav_pages,
				post_navigation : '<!-- post_navigation -->',
				photo_navigation : nav_photo,
				content: html
			};
			createWithGenTemplate('${App.EXPORT_FOLDER}/${folder}', 'index.html', template, templateObj);
		}
	}

	function generateThumb (photo:Photo){
		if(isOverWrite || !FileSystem.exists('${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${App.THUMB}/${photo.fileName}.jpg')){
			var command = Sys.command('convert',[
				"-resize", "200x200",
				"-define", "filter:blur=5",
				'${projectFolder}${photo.url}',
				'${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${App.THUMB}/${photo.fileName}.jpg'
			]);
			if(command == 0){
				Sys.println('\t+ thumb -> create for ${photo.fileName}');
			} else {
				Sys.println('- something went wrong $command');
			}
		}
	}

	function generatePhotoSizes(photo:Photo){
		for ( size in App.photoFileSizeArray ) {
			// [mck] check if file exists and isOverWrite is true;
			if(isOverWrite || !FileSystem.exists('${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${size}/${photo.fileName}.jpg')){
				var command = Sys.command('convert',[
					"-resize", '${size}x${size}',
					'${projectFolder}${photo.url}',
					'${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${size}/${photo.fileName}.jpg'
				]);
				if(command == 0){
					Sys.println('\t+ photo -> create ${size} for ${photo.fileName}');
				} else {
					Sys.println('- something went wrong $command');
				}
			}
			if(isJpegOptim){
				var command = Sys.command('jpegoptim', [
					'${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${size}/${photo.fileName}.jpg'
				]);
				if(command == 0){
					Sys.println('\t+ optimize -> ${photo.fileName}');
				} else {
					Sys.println('- something went wrong $command');
				}
			}
		}
	}


	// ____________________________________ sort Pages/Posts ____________________________________

	private function sortPhotos(photos:Array<Photo>){
		if (photos.length > 0) {
			haxe.ds.ArraySort.sort(photos, function(a, b) {
				var x = a.folders;
				var y = b.folders;

				if (x < y ) {
					return -1;
				} else  {
					return 1;
				}
			});
		}
	}

	private function sortPosts(posts:Array<Post>) : Void
	{
		if (posts.length > 0) {
			// Sorting by getTime() doesn't seem to work, for some reason; sorting by
			// the stringified dates (yyyy-mm-dd format) does.
			haxe.ds.ArraySort.sort(posts, function(a, b) {

				// USA way of formatting
				var x = a.createdOn.format("%Y-%m-%d");
				var y = b.createdOn.format("%Y-%m-%d");

				if(dateFormat != 'YYYY-mm-dd'){
					// EURO way of formatting
					x = a.createdOn.format("%d-%m-%Y");
					y = b.createdOn.format("%d-%m-%Y");
				}

				if (x < y ) { return 1; }
				else if (x > y) { return -1; }
				else { return 0; };
			});
		}
	}

	// Performs a sort on pages itself. Orders by "order" field.
	private function sortPages(pages:Array<Page>) : Void
	{
		if (pages.length > 0) {
			haxe.ds.ArraySort.sort(pages, function(a, b) {
				var x = a.order;
				var y = b.order;

				if (x < y ) { return -1; }
				else if (x > y) { return 1; }
				else {
						// if tied, sort by title ascending
						var m = a.title;
						var n = b.title;
						if (m < n) { return -1; }
						else if (m > n) { return 1; }
						else { return 0; };
				}
			});
		}
	}

	// ____________________________________ get Pages/Posts/Photos ____________________________________

	private function getPages(srcDir:String):Array<Page> {
		var pages:Array<Page> = new Array<Page>();
		var _arr = ignoreFilesOrFolders(FileSystem.readDirectory('${projectFolder}/${App.PAGES}'),[]);
		for ( i in 0 ... _arr.length ) {
			var file = '${projectFolder}/${App.PAGES}/${_arr[i]}';
			var p = new Page();
			p.parse(file);
			pages.push(p);
		}
		sortPages(pages);
		return pages;
	}

	function getPhotos(srcDir:String):Array<Photo> {
		var photos:Array<Photo> = new Array<Photo>();
		var arr = ignoreFilesOrFolders(FileSystem.readDirectory('${projectFolder}/${App.PHOTOS}'),[]);
		for ( i in 0 ... arr.length ) {
			// [mck] only check the folders in PHOTOS folder but not there subfolders
			var arr2 = ignoreFilesOrFolders(FileSystem.readDirectory('${projectFolder}/${App.PHOTOS}/${arr[i]}'),['json','md']);
			for ( j in 0 ... arr2.length ) {
				var file = '${projectFolder}/${App.PHOTOS}/${arr[i]}/${arr2[j]}';
				var p = new Photo();
				p.parse(file);
				photos.push(p);
			}
		}
		sortPhotos(photos);
		return photos;
	}

	private function getPosts(srcDir:String):Array<Post> {
		var posts:Array<Post> = new Array<Post>();
		var _arr = ignoreFilesOrFolders(FileSystem.readDirectory('${projectFolder}/${App.POSTS}'),[]);
		for ( i in 0 ... _arr.length ) {
			var file = '${projectFolder}/${App.POSTS}/${_arr[i]}';
			var p = new Post();
			p.parse(file);
			posts.push(p);
		}
		sortPosts(posts);
		return posts;
	}

	// ____________________________________ utils ____________________________________

	/**
	 *  Some folders are ignored by default
	 *
	 *  @param arr 					array of folders or files that need to be checked
	 *  @param ignoreArr 			(optional) an array with extensions you want to ignore: ['json','md','gif']
	 *  @return Array<String>		array with files and folders that are save to use
	 */
	function ignoreFilesOrFolders(arr:Array<String>, ?ignoreArr:Array<Dynamic>):Array<String>{
		var _arr = [];
		for ( i in 0 ... arr.length ) {
			var fileOrFolder = arr[i];
			if(fileOrFolder.startsWith(".")) continue; 			// ignore invisible (OSX) files like ".DS_Store"
			if(fileOrFolder.startsWith('_')) continue; 			// ignore files starting with "_"

			// [mck] ignore these files/folders
			if(fileOrFolder == App.EXPORT_FOLDER) continue;			// ignore export (www) folder
			if(fileOrFolder == App.PAGES) continue;					// ignore pages folder
			if(fileOrFolder == App.POSTS) continue;					// ignore post folder
			if(fileOrFolder == App.THUMB) continue;					// ignore thumb folder
			if(fileOrFolder == 'config.json') continue;			// ignore config.json
			if(fileOrFolder.startsWith('theme')) continue;		// ignore any folder that starts with "theme"

			// add an array with extensions you want to ignore
			if(ignoreArr != null && ignoreArr.length != 0){
				var isValid = true;
				for ( j in 0 ... ignoreArr.length ) {
					if(fileOrFolder.indexOf('.${ignoreArr[j]}') != -1 ){
						isValid = false;
						continue;
					}
				}
				if ( isValid ) _arr.push(fileOrFolder);
			} else {
				_arr.push(fileOrFolder);
			}
		}
		return _arr;
	}

	/**
	 *  copy files from original folder to www folder
	 *
	 *  @param folder -
	 *  @param fileArray -
	 */
	function copyFiles(folder:String,fileArray:Array<String>){
		var arr = FileSystem.readDirectory(folder);
		for ( i in 0 ... arr.length ) {
			var fileOrFolder = arr[i];
			if(FileSystem.isDirectory('$folder/$fileOrFolder')){
				if(fileOrFolder.startsWith('_')) continue;
				copyFiles('$folder/$fileOrFolder',fileArray);
			} else {
				var fileName = fileOrFolder.split('.')[0];
				var fileExt = fileOrFolder.split('.')[1].toLowerCase();

				if(fileName.startsWith('_')) continue;
				if(fileName.startsWith('.')) continue;

				if(fileArray.indexOf(fileExt) != -1){
					var wwwFolder = '${projectFolder}/${App.EXPORT_FOLDER}/${folder.replace(projectFolder, '')}';
					if(!FileSystem.exists(wwwFolder)){
						FileSystem.createDirectory(wwwFolder);
						Sys.println('\t\tcreate folder: ${wwwFolder.replace(projectFolder, '')}');
					}
					try{
						File.copy('$folder/$fileOrFolder', '$wwwFolder/$fileOrFolder');
						Sys.println('\t+ copy -> ${fileArray} to: ${wwwFolder.replace(projectFolder, '').replace('//','/')}/$fileOrFolder');
					} catch(e:Dynamic){
						trace(e);
					}
				}
			}
		}
	}

	// ____________________________________ create !!! ____________________________________

	function createDummyImage(path:String, label:String, filename:String, ?color:String = 'white', ?size:Int=3840){
		Sys.command('convert',[
						'-size', '${size}x${size/2}',
						'-background', '$color',
						'-gravity', 'center',
						'label:$label',
						'${projectFolder}/$path/$filename.jpg'
					]);
		Sys.println('\t+ dummy -> create dummy image: $path/$filename.jpg');
	}

	/**
	 *  create files with templates
	 *
	 *  @param path -
	 *  @param name -
	 *  @param template -
	 *  @param templateObj -
	 */
	function createWithGenTemplate(path:String, name:String, template:String, templateObj:Dynamic) : Void {

		// trace(path, name, 'template', 'html', nav, title);

		var defaultTemplateObj = {
			site_title : config.monkTitle,
			theme_dir : config.monkTheme,
			backgroundcolor: config.monkBackgroundcolor,
		}
		// trace(templateObj);

		var obj = Reflect.copy(defaultTemplateObj);
		for( ff in Reflect.fields(templateObj) ){
			Reflect.setField (obj, ff, Reflect.field(templateObj, ff));
		}



		trace(obj);

        var t = new haxe.Template(template);
        var output = t.execute(obj);
		// [mck] if this is the root, do nothing, if this is other folder add css to correct folder
		if('$path/$name' != '${App.EXPORT_FOLDER}/index.html') output =  output.replace('${config.monkTheme}','../../${config.monkTheme}').replace('href="favicon.ico"','href="../../favicon.ico"');
		createFile(path, name, output);
		// Sys.println('\tcreate template in "${path}/${name}"');
	}

	function createDir(name:String) {
		if (!FileSystem.exists(projectFolder + name)) {
			try {
				Sys.println('\t+ folder - create: $name');
			} catch(e:Dynamic){
				trace(e);
			}
		}
		FileSystem.createDirectory(projectFolder + name);
	}

	function createFile (path:String, name:String, content:String) {
		// remove projectFolder from path, just to be sure
		sys.io.File.saveContent(projectFolder + path.replace(projectFolder,'') + '/' + name, content);
		Sys.println('\t+ file -> create: ${path.replace(projectFolder,'')}/$name');
	}

	function createFavicon() : Void
	{
		var bytes = haxe.Resource.getBytes('favicon');
		var fo:FileOutput = sys.io.File.write(projectFolder + App.EXPORT_FOLDER + '/favicon.ico', true);
		fo.write(bytes);
		fo.close();
		Sys.println('\t+ favicon -> create!');
	}


	// ____________________________________ help ____________________________________

	function showHelp(){
		Sys.println('
${App.MONK} version ${App.VERSION}

how to use:
haxelib run monk [action] [options]

	[action]:
		scaffold 	: generate a folder structure with basic helper files
		generate	: generate static site
		clear		: cleanup www folder

	[options]
		-force 		: overwrite existing files
		-optim 		: use jpg optimasation

');
	}

	static public function main () {
		var app = new Run ();
	}
}



