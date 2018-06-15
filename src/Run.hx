package;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

import monk.core.Config;
import monk.core.Page;
import monk.core.Post;
import monk.core.Photo;
import monk.core.Statics;
import monk.model.constants.App;

using StringTools;
using DateTools;

class Run {

	var projectFolder : Dynamic;
	var args : Array<String>  = Sys.args ();
	var current = Sys.getCwd ();

	var fileExtArr = ['jpg', 'jpeg', 'png', 'gif'];
	// var fileSizeArr = [3840, 2560, 1920, 1280, 1024, 640];

	var config : Config;
	var dateFormat : String = 'dd-mm-YYYY';

	var isFirst : Bool = true; // check only once
	var isJpegOptim : Bool = false;
	var isOverWrite : Bool = false;

	public function new () {
		Sys.println('${App.MONK} - version: ${App.VERSION} - build: ${App.BUILD}');

		args = Sys.args();
		projectFolder = args[args.length-1];

		Sys.println('\tfolder: ${projectFolder}');
		Sys.println('\targs: ${args}\n');

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
					// [mck] make sure there is an yes and no possibility
					FileSystem.deleteDirectory('${projectFolder}/${App.EXPORT_FOLDER}');
				case 'test':
					initTest();
				case 'scaffold', 'scafold', 'skafold', 'skaffold':
					initScaffold();
				case 'prepare':
					imagePrepare(projectFolder);
				case 'generate':
					initGenerate();
				case 'update':
					updateTheme();
				case 'minify':
					minifyImages(projectFolder);
				default :
					showHelp();
			}
		}
	}

	// ____________________________________ init function ____________________________________

	function initGenerate(){
		Sys.println (':: ${App.MONK} :: generate');

		// [mck] overwrite theme0 to be always up to date
		setupTheme('${App.THEME_FOLDER_DEFAULT}');
		// favicon
		createFavicon();

		// [mck] load existing config
		config = Config.init('${projectFolder}/config.json');

		// copy files from "theme" (defined in config) the same folder in "www" / export folder
		copyFiles('${projectFolder}/${config.monkTheme}', ['css','js','png','jpg', 'gif']);
		// copy img folder (might need to be extended to photo-folder/page-folder/post-folder)
		copyFiles('${projectFolder}/${App.IMG}', fileExtArr);
		// copy statics
		copyFiles('${projectFolder}/${App.STATICS}', ['html', 'htm', 'css','js','png','jpg', 'gif']);

		// Start creating content files
		var pages:Array<Page> = getPages(projectFolder);
		var posts:Array<Post> = getPosts(projectFolder);
		var photos:Array<Photo> = getPhotos(projectFolder);
		var statics:Array<Statics> = getStatics(projectFolder);
		var tags:Array<String> = Post.getPostTags(posts);

		Sys.println('\t+ tags -> list: ${tags}');

		// Start HTML generation
		generateHtmlPages(posts, pages, photos, statics);
		// generateRssFeed(posts, binDir, config);
	}

	/**
	 *  scaffold a Monk project with images, folders, config, etc
	 *  the whole shabang
	 */
	function initScaffold(){
		Sys.println (':: ${App.MONK} :: scaffold');

		if(!FileSystem.exists('${projectFolder}')) return;

		// [mck] load existing config / or use default values
		config = Config.init('${projectFolder}/config.json');

		// create export files
		createDir(App.EXPORT_FOLDER);
		createDir(App.IMG);
		createDummyImage(App.IMG,'test', 'test', 'green', 200);
		createDummyImage(App.IMG,'social', 'social', 'white', 300); // should be minimal 280x150px
		createFavicon();
		setupStatics();
		setupPostAndPages();
		setupPhoto();
		setupTheme('${App.THEME_FOLDER_DEFAULT}');
		setupConfig();
		setupData();

		// read rest folders
		var _arr = FileSystem.readDirectory('${projectFolder}');
		for ( i in 0 ... _arr.length ) {

			var fileName = _arr[i];

			if(fileName.startsWith(".")) continue; 			// ignore invisible (OSX) files like ".DS_Store"
			if(fileName.startsWith('_')) continue; 			// ignore files starting with "_"

			// [mck] ignore these files/folders
			if(fileName == App.EXPORT_FOLDER) continue;		// ignore www (export) folder
			if(fileName == App.IMG) continue;				// ignore img folder
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
				if(fileOrFolder == App.IMG) continue; // ignore IMG folder
				imagePrepare('$folder/$fileOrFolder');
			} else {
				var fileName = fileOrFolder.split('.')[0];
				var fileExt = fileOrFolder.split('.')[fileOrFolder.split('.').length - 1].toLowerCase();

				if(fileName.startsWith('_')) continue;
				if(fileName.startsWith('.')) continue;

				if(fileExtArr.indexOf(fileExt) != -1){
					// [mck] create positioning file for text
					var obj = {
						"top": '${Std.random(5)*10}px',
						"left": '${Std.random(5)*10}px',
						"width": '${(Std.random(5)*10)+50}%',
						"height": '${(Std.random(5)*10)+50}%',
						"textcolor": "#ffffff"
					}

					// [mck] json file used for positioning short info over picture
					if(FileSystem.exists('${folder}/${fileName}.json') || FileSystem.exists('${folder}/_${fileName}.json')  ){
						Sys.println('\t\t>> ${fileName}.json or _${fileName}.json already exists');
					} else {
						createFile('${folder}', '${fileName}.json', haxe.Json.stringify(obj));
					}

					// [mck] md file used for short info over picture
					if(FileSystem.exists('${folder}/${fileName}.md') || FileSystem.exists('${folder}/_${fileName}.md')  ){
						Sys.println('\t\t>> ${fileName}.md or _${fileName}.md already exists');
					} else {
						// createFile('${folder}', '${fileName}.md', '# ${fileName}\n\nText over photo\n\nAnother line about the photo!');
						createFile('${folder}', '${fileName}.md', '# ${fileName}\n\n# Paper joints\n\nPaper is not really strong (even when you use 200 grams paper) and bending it wil make it even weaker.\n\nSo joints are the way to make possible paper.\n\nVery happy with the result! And an added bonus: my hands look like \'[strandbeesten](http://www.strandbeest.com/photos.php)\'');
					}

					// [mck] more indepth story about the photo
					if(FileSystem.exists('${folder}/${fileName}_post.md') || FileSystem.exists('${folder}/_${fileName}_post.md')){
						Sys.println('\t\t>> ${fileName}_post.md or _${fileName}_post.md already exists');
					} else {
						createFile('${folder}', '${fileName}_post.md', '# ${fileName}\n\nMore indepth info about this image');
					}

				}
			}
		}
	}

	function updateTheme (){
		// [mck] overwrite theme0 to be always up to date
		setupTheme('${App.THEME_FOLDER_DEFAULT}');
	}

	// ____________________________________ setup ____________________________________

	function setupPhoto(){
		createDir(App.PHOTOS);
		createDir('${App.PHOTOS}/monk');
		createDir('${App.PHOTOS}/_ignorefolder');
		createDir('${App.PHOTOS}/00_ccc');
		createDir('${App.PHOTOS}/01_bbb');
		createDir('${App.PHOTOS}/02_aaa');

		createDummyImage('${App.PHOTOS}/monk','white image','white');
		createDummyImage('${App.PHOTOS}/monk','pink image','pink', 'pink');
		createDummyImage('${App.PHOTOS}/monk','ignore image','_ignore', 'Plum');

		createDummyImage('${App.PHOTOS}/00_ccc','ccc','ccc', 'Aqua');
		createDummyImage('${App.PHOTOS}/01_bbb','bbb','bbb', 'CornflowerBlue');
		createDummyImage('${App.PHOTOS}/02_aaa','aaa','aaa', 'DarkOrange');
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

	/**
	 *  (html) files that have no connection to Monk what-so-every
	 */
	function setupStatics(){
		createDir(App.STATICS);

		createFile(App.STATICS, 'fake.css', '/* this is totally fake\n-------------------------------------------- */');

		createDir(App.STATICS + '/public');
		createDir(App.STATICS + '/public/css');
		createDir(App.STATICS + '/public/img');
		createDir(App.STATICS + '/public/js');
		createFile(App.STATICS + '/public/css/', 'fake.css', '/* this is totally fake\n-------------------------------------------- */');

		createFile(App.STATICS, 'dashboard.html' , haxe.Resource.getString('staticDashboardTemplate'));
		createFile(App.STATICS, 'cover.html' , haxe.Resource.getString('staticCoverTemplate'));
	}

	function setupTheme(name:String){
		createDir('${name}');
		createDir('${name}/img');

		// trace(name);
		// trace('${projectFolder}/${name}/img');


		// copyFiles('${projectFolder}/${name}/img', ['png','jpg']);

		createFile('${name}', 'monk.css', haxe.Resource.getString('css'));
		createFile('${name}', 'monk.js', haxe.Resource.getString('js'));
		createFile('${name}', 'index.html', haxe.Resource.getString('indexTemplate'));
		createFile('${name}', 'index-post.html', '');
		createFile('${name}', 'post.html', haxe.Resource.getString('postTemplate'));
		createFile('${name}', 'page.html', haxe.Resource.getString('pagesTemplate'));
		createFile('${name}', 'info.html', haxe.Resource.getString('infoTemplate'));
	}

	function setupConfig(){
		// var obj : ConfigObj = {
		var obj : Dynamic = {
			"site_title" : config.monkTitle,
			"site_url": config.monkSiteUrl,
			"theme_dir" : config.monkTheme,
			"social_button": config.monkIsSocial,
			"backgroundcolor" : config.monkBackgroundcolor,
			"description" : "Monk a static site generator",
			"author" : "Matthijs Kamstra",
			"googleAnalytics" : config.googleAnalytics
		}
		createFile('', 'config.json', haxe.Json.stringify(obj));
	}

	function setupData(){
		var path = '${App.EXPORT_FOLDER}/${App.DATA}';
		createDir(path);
		createFile(path, '.gitkeep', '');
	}

	// ____________________________________ generate ____________________________________

	function generateHtmlPages(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>, statics:Array<Statics>) {
		generateHtmlFilesForPages(posts, pages, photos, statics);
		generateHtmlFilesForPosts(posts, pages, photos, statics);
		generatePhotos(posts, pages, photos, statics);
		generateJson(posts, pages, photos, statics);
	}

	private function generateJson(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>, statics:Array<Statics>) {

		// trace('generateJson');
		// trace('posts -> '+posts.length);
		// trace('pages -> '+pages.length);
		// trace('photos -> '+photos.length);
		// trace('statics -> '+statics.length);

		var path = '${App.EXPORT_FOLDER}/${App.DATA}';
		var postsContent = '';
		var pagesContent = '';
		var photosContent = '';
		var staticsContent = '';
		var totalContent = '';


		// trace('1');
		createDir(path);
		// trace('2');



		postsContent += '\n"posts":[\n';
		for (i in 0...posts.length){
			var _posts : Post = posts[i];

			// trace('${i} - ${_posts.id}');
			Reflect.deleteField (_posts, 'projectFolder'); 	// folder is on my harddrive, don't need to share that
			// postsContent += '\t{"url": "${_posts.url}"}';
			postsContent += '\t${haxe.Json.stringify(_posts)}';
			postsContent += (i != pages.length-1) ? ',\n' : '\n';
		}
		postsContent += ']\n';


		pagesContent += '\n"pages":[\n';
		for (i in 0...pages.length){
			var _pages : Page = pages[i];
			Reflect.deleteField (_pages, 'projectFolder'); 	// folder is on my harddrive, don't need to share that
			// pagesContent += '\t{"url": "${_pages.url}"}';
			pagesContent += '\t${haxe.Json.stringify(_pages)}';
			pagesContent += (i != pages.length-1) ? ',\n' : '\n';
		}
		pagesContent += ']\n';

		// trace('4');

		photosContent += '\n"photos":[\n';
		for (i in 0...photos.length){
			var _photos : Photo = photos[i];
			// _photos.path = '';
			// _photos.projectFolder = '';
			Reflect.deleteField (_photos, 'path');			 	// folder is on my harddrive, don't need to share that
			Reflect.deleteField (_photos, 'projectFolder'); 	// folder is on my harddrive, don't need to share that
			Reflect.setProperty (_photos, 'html',  generateHomepageBlock (_photos));
			photosContent += '\t${haxe.Json.stringify(_photos)}';
			photosContent += (i != photos.length-1) ? ',\n' : '\n';
		}
		photosContent += ']\n';

		// trace('5');

		staticsContent += '\n"statics":[\n';
		for (i in 0...statics.length){
			var _statics : Statics = statics[i];
			Reflect.deleteField (_statics, 'projectFolder'); 	// folder is on my harddrive, don't need to share that
			// staticsContent += '\t{"url": "${_statics.url}"}';
			staticsContent += '\t${haxe.Json.stringify(_statics)}';
			staticsContent += (i != statics.length-1) ? ',\n' : '\n';
		}
		staticsContent += ']\n';

		totalContent += pagesContent + ',' + photosContent + ',' +  postsContent + ',' +  staticsContent;

		// trace('6');

		createFile (path, 'pages.json', '{${pagesContent}}');
		createFile (path, 'posts.json', '{${postsContent}}');
		createFile (path, 'photos.json', '{${photosContent}}');
		createFile (path, 'statics.json', '{${staticsContent}}');
		createFile (path, 'total.json', '{${totalContent}}');

		// trace('7 end');
	}

	private function generateHtmlFilesForPages(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>, statics:Array<Statics>) {
		// var template = haxe.Resource.getString('pagesTemplate');
		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/page.html' );
		for (page in pages) {
			var templateObj = {
				title: page.title,
				page_navigation : convertPageList(pages),
				post_navigation : convertPostList(posts),
				photo_navigation : convertPhotoList(photos),
				static_navigation : convertStaticsList(statics),
				googleAnalyticsScript : convertAnalytics(),
				content: page.content
			};
			createWithGenTemplate(App.EXPORT_FOLDER, '${page.url}.html', template, templateObj);
		}
	}

	private function generateHtmlFilesForPosts(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>, statics:Array<Statics>) {
		createDir('${App.EXPORT_FOLDER}/${App.POSTS}');
		// var str = haxe.Resource.getString('postTemplate');
		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/post.html');
		var newsTemplate = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/page.html');
		var html = '<div class="row"><div class="col-md-8">';
		for (post in posts) {
			var obj = {
				title: post.title,
				page_navigation: convertPageList(pages),
				content : post.content
			}
			createWithGenTemplate('${App.EXPORT_FOLDER}/${App.POSTS}', '${post.url}.html', template, obj);
			html += '<h1>${post.title}</h1>
					<p><i class="fas fa-link"></i> ${post.createdOn}</p>
					<p>${post.content}</p>
					<a href="${App.EXPORT_FOLDER}/${App.POSTS}/${post.url}.html" class="btn btn-link" role="button">Read more</a>
					<hr>';
		}
		html += '</div>';
		html += '<div class="col-md-4">${convertPostList(posts)}</div>';
		html += '</div>';

		var templateObj = {
			title : 'News',
			page_navigation : convertPageList(pages,'../'),
			post_navigation : convertPostList(posts, '../../'),
			photo_navigation : convertPhotoList(photos,'../'),
			static_navigation : convertStaticsList(statics,'../'),
			googleAnalyticsScript : convertAnalytics(),
			content: html
		};
		createWithGenTemplate('${App.EXPORT_FOLDER}/${App.POSTS}', 'index.html', newsTemplate, templateObj);
	}

	private function convertAnalytics(){
		var analytics = '';
		// lame but just a simple check
		if(config.googleAnalytics != null && config.googleAnalytics.length > 4){

			var template = haxe.Resource.getString('googleAnalyticsTemplate');
			var t = new haxe.Template(template);
			var output = t.execute({"googleAnalytics" : config.googleAnalytics});
			analytics = output;
		}
		return analytics;
	}

	/**
	 *  convert the pages array to a navigation list
	 *
	 *  @param pages 		array with `Page`
	 *  @param path			hack the correct path
	 *  @return String
	 */
	private function convertPageList(pages:Array<Page>, path:String=''):String{
		var nav = '';
		for(page in pages){
			var klass = '';
			nav += '<li class="nav-item"><a class="nav-link" href="${path}${page.url}.html">${page.title}</a></li>';
		}
		return nav;
	}

	/**
	 *  convert the posts array to a navigation list
	 *
	 *  @param posts		array with `Post`
	 *  @param path			hack the correct path
	 *  @return String
	 */
	private function convertPostList(posts:Array<Post>, path:String=''):String{
		var nav = '';
		for(post in posts){
			var klass = '';
			nav += '<li${klass}><a href="${path}${post.url}.html">${post.title}</a></li>';
		}
		return nav;
	}

	/**
	 *  convert the statics array to a navigation list
	 *
	 *  @param statics		array with `Post`
	 *  @param path			hack the correct path
	 *  @return String
	 */
	private function convertStaticsList(statics:Array<Statics>, path:String=''):String{
		var nav = '';
		for(stat in statics){
			var klass = '';
			// nav += '<li${klass}><a href="${path}${post.url}.html">${post.title}</a></li>';
			// nav += '<a class="dropdown-item" href="${path}${statics.url}.html">${statics.title}</a>';
			nav += '<a class="dropdown-item" href="${path}${App.STATICS}/${stat.url}.html" target="_blank"><i class="fas fa-external-link-alt fa-xs"></i> ${stat.title}</a>';
		}
		return nav;
	}

	/**
	 *  convert the photos array to a navigation list
	 *
	 *  @param photos 		array with `Photo`
	 *  @param path			hack the correct path
	 *  @return String
	 */
	private function convertPhotoList(photos:Array<Photo>, path:String=''):String{
		var tempSubArr = [];
		// create photo folders
		for (photo in photos){
			// store unique folder names in arr
			if(tempSubArr.indexOf(photo.folders) == -1) tempSubArr.push(photo.folders);
		}
		var nav_photo = '';
		for(folder in tempSubArr){
			var klass = '';
			// if(page.title == p.title) klass = ' class="active"';
			// var temp = '';
			// nav_photo += '<li${klass}><a href="${folder}/index.html">${folder.split('/')[1]}</a></li>';
			nav_photo += '<a class="dropdown-item" href="${folder}/index.html">${folder.split('/')[1]}</a>';
		}
		nav_photo = nav_photo.replace('${App.PHOTOS}/','${path}${App.PHOTOS}/');
		return nav_photo;
	}


	/**
	 *  TODO use `cleanfolder` to generate folder structure, it will be more nice url
	 *
	 *  http://www.foo.bar/photos/aaa/
	 *  instead of
	 *  http://www.foo.bar/photos/03_aaa/
	 *
	 *  @param photos -
	 *  @param pages -
	 */
	private function generatePhotos(posts:Array<Post>, pages:Array<Page>, photos:Array<Photo>, statics:Array<Statics>){
		createDir('${App.EXPORT_FOLDER}/${App.PHOTOS}');

		var template = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/index.html');
		var templateInfo = sys.io.File.getContent( '${projectFolder}/${config.monkTheme}/info.html');

		var tempSubArr = [];

		// create photo folders
		for (photo in photos){
			// store unique names in arr
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

		for(folder in tempSubArr){
			var html = '';
			for (photo in photos){
				// trace(photo.folders, folder, photo.fileName);
				if (photo.folders == folder){
					var thumb = '${photo.folders}/${App.THUMB}/${photo.fileName}.jpg';
					var infoBtn = (photo.post != '') ? '<p><a href="${photo.folders}/${photo.fileName}.html" class="btn btn-link">More info <i class="fas fa-angle-right"></i></a></p>' : '';
					html += '
						<div class="slide" data-width="${photo.width}" data-height="${photo.height}" style="background-image: url($thumb);">
							<a name="${photo.fileName}" class="internal"><i class="fas fa-link"></i></a>
							<div class="post" data-style="${(photo.style).urlEncode()}" ${photo.nostyle}>
								<div class="content">
									<a href="#${photo.fileName}" class="link"><i class="fas fa-link"></i></a>
									${photo.description} ${infoBtn}
								</div>
							</div>
							<img src="${thumb}" class="full" data-folder="${photo.folders}" data-img="${photo.fileName}.jpg" width="${photo.width}" height="${photo.height}">
							<br class="clearfix">
						</div>
					'.replace('\t','').replace('\n',''); // strip tabs and returns

					// [mck] I am going to duplicate the code, sorry about that ... maybe it will be better later down the track
					// changes need to be made in two functions
				}
			}

			// http://www.foo.nl/index.html
			if(isFirst){
				var templateObj = {
					title : 'Gallery',
					page_navigation : convertPageList(pages),
					post_navigation : convertPostList(posts),
					photo_navigation : convertPhotoList(photos),
					static_navigation : convertStaticsList(statics),
					googleAnalyticsScript : convertAnalytics(),
					content: html
				};
				createWithGenTemplate(App.EXPORT_FOLDER, 'index.html', template, templateObj);
				isFirst = false;
			}

			html = html.replace('${folder}/','');

			// http://www.foo.nl/bar/index.html
			var templateObj = {
				title : 'Gallery',
				page_navigation : convertPageList(pages, '../../'),
				post_navigation : convertPostList(posts, '../../'),
				photo_navigation : convertPhotoList(photos, '../../'),
				static_navigation : convertStaticsList(statics, '../../'),
				googleAnalyticsScript : convertAnalytics(),
				content: html
			};
			createWithGenTemplate('${App.EXPORT_FOLDER}/${folder}', 'index.html', template, templateObj);

			// [mck] generate all info files
			for (photo in photos){
				var backgroundImage = '${App.THUMB}/${photo.fileName}.jpg';
				var parallaxImage = '${App.photoFolderArray[0]}/${photo.fileName}.jpg';
				var previewImage = '${App.photoFolderArray[3]}/${photo.fileName}.jpg';

				var postHtml = '<a href="./index.html" role="button" class="bttn bttn-link"><i class="fas fa-angle-right"></i> Back</a>';
				postHtml += photo.post;
				postHtml += '<img src="${previewImage}" alt="${photo.fileName}">';

				if(photo.post != ''){
					var templateObj = {
						title : photo.folder + ' | ' + photo.fileName,
						page_navigation : convertPageList(pages, '../../'),
						post_navigation : convertPostList(posts, '../../'),
						photo_navigation : convertPhotoList(photos, '../../'),
						static_navigation : convertStaticsList(statics, '../../'),
						googleAnalyticsScript : convertAnalytics(),
						backgroundimage: backgroundImage,
						parallaximage: parallaxImage,
						content: postHtml
					};
					createWithGenTemplate('${App.EXPORT_FOLDER}/${photo.folders}', '${photo.fileName}.html', templateInfo, templateObj);
				}
			}
		}
	}


	function generateHomepageBlock (photo:Photo) : String {
		var thumb = '${photo.folders}/${App.THUMB}/${photo.fileName}.jpg';
		var infoBtn = (photo.post != '') ? '<p><a href="${photo.folders}/${photo.fileName}.html" class="btn btn-link">More info <i class="fas fa-angle-right"></i></a></p>' : '';
		var html = '
			<div class="slide" data-width="${photo.width}" data-height="${photo.height}" style="background-image: url($thumb);">
				<a name="${photo.fileName}" class="internal"><i class="fas fa-link"></i></a>
				<div class="post" data-style="${(photo.style).urlEncode()}" ${photo.nostyle}>
					<div class="content">
						<a href="#${photo.fileName}" class="link"><i class="fas fa-link"></i></a>
						${photo.description} ${infoBtn}
					</div>
				</div>
				<img src="${thumb}" class="full" data-folder="${photo.folders}" data-img="${photo.fileName}.jpg" width="${photo.width}" height="${photo.height}">
				<br class="clearfix">
			</div>
		'.replace('\t','').replace('\n',''); // strip tabs and returns
		return html;
	}

	function minifyImages(folder){
		Sys.println('\t+ minifyimages -> ${folder}');

		var arr = FileSystem.readDirectory(folder);
		for ( i in 0 ... arr.length ) {
			var fileOrFolder = arr[i];
			if(FileSystem.isDirectory('$folder/$fileOrFolder')){
				minifyImages('$folder/$fileOrFolder');
			} else {
				var fileName = fileOrFolder.split('.')[0];
				var fileExt = fileOrFolder.split('.')[fileOrFolder.split('.').length - 1].toLowerCase();

				// trace('$i, $fileOrFolder, $fileName, $fileExt');

				// if(fileName.startsWith('_')) continue;
				if(fileOrFolder.startsWith('.')) continue;
				if(fileExt.endsWith('gif')) continue;
				if(fileExt.startsWith('min')) continue;

				// trace('----->> $i, $fileOrFolder, $fileName, $fileExt');

				var command = Sys.command('convert',[
					'${folder}${fileOrFolder}',
					'-sampling-factor', '4:2:0',
					'-strip',
					'-quality', '85',
					'-interlace', 'JPEG',
					'-colorspace', 'sRGB',
					'${folder}/${fileName}.min.jpg'
				]);

			}
		}

	}

	function generateThumb (photo:Photo){
		if(isOverWrite || !FileSystem.exists('${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${App.THUMB}/${photo.fileName}.jpg')){
			var command = Sys.command('convert',[
				"-resize", "200x200",
				"-define", "filter:blur=5",
				'${projectFolder}${photo.url}',
				'-sampling-factor', '4:2:0',
				'-strip',
				'-quality', '85',
				'-interlace', 'JPEG',
				'-colorspace', 'sRGB',
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
					'-sampling-factor', '4:2:0',
					'-strip',
					'-quality', '85',
					'-interlace', 'JPEG',
					'-colorspace', 'sRGB',
					'${projectFolder}/${App.EXPORT_FOLDER}/${photo.folders}/${size}/${photo.fileName}.jpg',
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


	// ____________________________________ sort Photos/Pages/Posts ____________________________________

	private function sortPhotos(photos:Array<Photo>){
		if (photos.length > 0) {
			haxe.ds.ArraySort.sort(photos, function(a, b) {
				var x = a.folders;
				var y = b.folders;

				// [mck] folders is good for sorting, cleanfolder wil be good for generation

				if (x < y ) {
					return -1;
				} else  {
					return 1;
				}
			});
		}
	}

	private function sortPosts(posts:Array<Post>) {
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
	private function sortPages(pages:Array<Page>) {
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

	// Performs a sort on statics itself. Orders by "order" field.
	private function sortStatics(pages:Array<Statics>) {
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

			Sys.println('\t+ pages -> read: ${_arr[i]}');
		}
		sortPages(pages);
		return pages;
	}

	/**
	 *  shallow scan from the `statics` folder
	 *  to create the links
	 *
	 *  @param srcDir - source of the project folder (huuuu doesn't do anything??)
	 *  @return Array<Statics>
	 */
	function getStatics(srcDir:String):Array<Statics> {
		var statics:Array<Statics> = new Array<Statics>();
		// make sure it only get the `.html` files, so ignore the rest
		var arr = ignoreFilesOrFolders(FileSystem.readDirectory('${projectFolder}/${App.STATICS}'),['css', 'js', 'gif', 'ico']);
		for ( i in 0 ... arr.length ) {
			var file = '${projectFolder}/${App.STATICS}/${arr[i]}';
			if(FileSystem.isDirectory('$file')) continue;
			if(file.indexOf('index.html') != -1 ) continue;

			// otherwise just add it
			var p = new Statics();
			p.parse(file);
			statics.push(p);

			Sys.println('\t+ statics -> read: ${arr[i]}');
		}
		sortStatics(statics);
		return statics;
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

				Sys.println('\t+ photos -> read: ${arr[i]}/${arr2[j]}');
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

			Sys.println('\t+ posts -> read: ${_arr[i]}');
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
			if(fileOrFolder.startsWith(".")) continue; 				// ignore invisible (OSX) files like ".DS_Store"
			if(fileOrFolder.startsWith('_')) continue; 				// ignore files starting with "_"

			// [mck] ignore these files/folders
			if(fileOrFolder == App.EXPORT_FOLDER) continue;			// ignore export (www) folder
			if(fileOrFolder == App.PAGES) continue;					// ignore pages folder
			if(fileOrFolder == App.POSTS) continue;					// ignore post folder
			if(fileOrFolder == App.THUMB) continue;					// ignore thumb folder
			if(fileOrFolder == App.STATICS) continue;				// ignore statics folder
			if(fileOrFolder == 'config.json') continue;				// ignore config.json
			if(fileOrFolder.startsWith('theme')) continue;			// ignore any folder that starts with "theme"

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
	 *  @param folder - the root folder you want to copy
	 *  @param fileArray -	the files you want to copy
	 */
	function copyFiles(folder:String, fileArray:Array<String>){

		// trace(folder, fileArray);

		var arr = FileSystem.readDirectory(folder);

		// trace(arr);

		for ( i in 0 ... arr.length ) {
			var fileOrFolder = arr[i];
			if(FileSystem.isDirectory('$folder/$fileOrFolder')){
				if(fileOrFolder.startsWith('_')) continue;
				copyFiles('$folder/$fileOrFolder',fileArray);
			} else {
				var fileName = fileOrFolder.split('.')[0];
				var fileExt = fileOrFolder.split('.')[fileOrFolder.split('.').length - 1].toLowerCase();

				// trace('-------------> $fileOrFolder');

				if(fileOrFolder.startsWith('_')) continue;
				if(fileOrFolder.startsWith('.')) continue;
				// trace('------------------------------> $fileOrFolder');
				// trace('------------------------------> $fileExt');

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

	/**
	 *  create dummy images
	 *
	 *  @param path - where do you want the file
	 *  @param label - a value you want written in the image
	 *  @param filename - file name is self explainable
	 *  @param color - color discription like "white" / "green"
	 *  @param size - size will be translated to:  width:size in px and height:size/2 in pixels
	 */
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
	 *  @param path 			path to save file
	 *  @param name 			name of file
	 *  @param template 		string content of template
	 *  @param templateObj 		object with extra data, lazy way of injecting data
	 */
	function createWithGenTemplate(path:String, name:String, template:String, templateObj:Dynamic) : Void {

		// trace(path, name, 'template', 'html', nav, title);

		// [mck] default config info
		var defaultTemplateObj = {
			site_title : config.monkTitle,
			theme_dir : config.monkTheme,
			backgroundcolor: config.monkBackgroundcolor,
			generator: config.monkGenerator
		}

		// [mck] merge objects (defaultTemplateObj and templateObj)
		var obj = Reflect.copy(defaultTemplateObj);
		for( ff in Reflect.fields(templateObj) ){
			Reflect.setField (obj, ff, Reflect.field(templateObj, ff));
		}
		// [mck] inject all data from config
		for( ff in Reflect.fields(config.monkConfig) ){
			Reflect.setField (obj, ff, Reflect.field(config.monkConfig, ff));
		}

        var t = new haxe.Template(template);
        var output = t.execute(obj);


		// [mck] if this is the root, do nothing, if this is other folder add css/favicon to correct folder
		var slashArr = '$path/$name'.split('/');
		var tpath = '';
		switch (slashArr.length) {
			case 2: tpath = '';
			case 3: tpath = '../';
			case 4: tpath = '../../';
			case 5: tpath = '../../../';
		}
		// trace(slashArr, slashArr.length, tpath);
		output =  output.replace('${config.monkTheme}','${tpath}${config.monkTheme}').replace('href="favicon.ico"','href="${tpath}favicon.ico"');

		createFile(path, name, output);
		// Sys.println('\tcreate template in "${path}/${name}"');
	}

	function createDir(name:String) {
		if (!FileSystem.exists(projectFolder + name)) {
			try {
				Sys.println('\t+ folder - create: $name');
			} catch(e:Dynamic){
				trace('oeps something went wrong');
				trace(e);
			}
		}
		FileSystem.createDirectory(projectFolder + name);
	}

	/**
	 *  create a file, with name and with content
	 *
	 *  @param path - where is the file created
	 *  @param name - name of the file
	 *  @param content - content of the file
	 */
	function createFile (path:String, name:String, content:String) {
		// remove projectFolder from path, just to be sure
		sys.io.File.saveContent(projectFolder + path.replace(projectFolder,'') + '/' + name, content);
		Sys.println('\t+ file -> create: ${path.replace(projectFolder,'')}/$name');
	}

	function createFavicon() {
		if(!FileSystem.exists(projectFolder + App.EXPORT_FOLDER + '/favicon.ico')){
			var bytes = haxe.Resource.getBytes('favicon');
			var fo:FileOutput = sys.io.File.write(projectFolder + App.EXPORT_FOLDER + '/favicon.ico', true);
			fo.write(bytes);
			fo.close();
			Sys.println('\t+ favicon -> create!');
		}
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
		prepare		: generate .json and .md files for images (ignore _ and . files)
		clear		: cleanup www folder
		update		: update/overwrite default "theme0" folder
		minify		: update images with minifed options

	[options]
		-force 		: overwrite existing files
		-optim 		: use jpg optimization

');
	}

	static public function main () {
		new Run ();
	}
}



