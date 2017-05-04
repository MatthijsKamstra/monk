package;

import js.jquery.JQuery;

import js.Browser.window;
import js.Browser.document;
import js.Browser.console;
import js.Browser.location;

import js.html.DivElement;

import monk.model.constants.App;
/**
 * @author Matthijs Kamstra aka [mck]
 */
class Main {

	// var slideArr : Array<Dynamic> = [];

	var divArr : Array<DivElement> = [];
	var divMap : Map<DivElement,Bool> = new Map();

	var isHomepage : Bool = false;

	public function new () {
		console.log('${App.MONK} version: ${App.VERSION}' );

		new JQuery(document).ready(function (e){
			console.log('${App.MONK} doc ready');
			if (new JQuery('body').hasClass('homepage')){
				isHomepage = true;
				initData();
				initScroll();
			} else {
				console.log('not homepage, init dropdown, and sideNav');

				untyped __js__ ('$(".dropdown-button").dropdown();');
				untyped __js__ ('$(".button-collapse").sideNav();');
			}
		});

		new JQuery(window).resize(function (e){
			console.debug('resized');
			if(isHomepage){
				initData();
				initScroll();
			}
		});

		new JQuery(window).scroll(function (e){
			if(isHomepage)
				initScroll();
		});
	}

	function initData(){
		divArr = [];
		divMap = new Map();
		var w = new JQuery(window).width();
		console.debug ('width: $w');
		new JQuery('.slide').each(function(i:Int,el:js.html.Element){
			divArr.push(js.Lib.nativeThis);
			divMap.set(js.Lib.nativeThis, false);
		});
		// [mck] start with first image
		updateImage(0, divArr[0]);
	}

	function initScroll(){
		var fromTop = new JQuery(document).scrollTop();

		if(fromTop>50) {
			new JQuery('.brand-name').addClass('brand-name-hide');
			new JQuery('#brand').addClass('brand-img-show');
			new JQuery('nav').addClass('hide');
		}

		if(fromTop<50) {
			new JQuery('.brand-name').removeClass('brand-name-hide');
			new JQuery('#brand').removeClass('brand-img-show');
			new JQuery('nav').removeClass('hide');
		}




		// if(fromTop>50) new JQuery('.brand-name').hide();
		// if(fromTop<50) new JQuery('.brand-name').show();

		for ( i in 0 ... divArr.length ) {
			var div = divArr[i];
			var isDone = divMap.get(div);

			// [mck] if this is set, just ignore
			if(isDone) continue;

			// [mck] check which element is currently visible
			var imgOffset = new JQuery(div).offset().top;
			var imgHeight = new JQuery(div).height();
			var imgBottomOffset = imgOffset + imgHeight;
			if(fromTop >= imgOffset && fromTop < imgBottomOffset) {
				// [mck] because we load the next image as well, we only need this element
				updateImage(i,div);
			}
		}
	}

	function updateImage(id, div){
		// [mck] set current div on true (is set)
		divMap.set(div, true);
		// [mck] make sure there is a next image
		if(id+1 > divArr.length) return;
		// [mck] create a array with current image and next
		var _arr = [div, divArr[id+1]];
		for ( i in 0 ... _arr.length ) {
			var _div = _arr[i];


			var folderSizeName = Std.string(App.photoFileSizeArray[App.photoFileSizeArray.length-1]);
			var w = new JQuery(window).width();
			for ( i in 0 ... App.photoFileSizeArray.length ) {
				var value = App.photoFileSizeArray[i];
				if(w <= value) folderSizeName = Std.string(value);
			}


			var dataFolder = new JQuery(_div).find('img').attr('data-folder');
			var dataImg = new JQuery(_div).find('img').attr('data-img');
			if(location.href.indexOf(dataFolder) != -1){
				var img = new JQuery(_div).find('img').attr('src','${folderSizeName}/${dataImg}');
			} else{
				var img = new JQuery(_div).find('img').attr('src','${dataFolder}/${folderSizeName}/${dataImg}');
			}
		}
	}


/*
	// slideArr = JQuery.makeArray(new JQuery('.slide'));

	// trace(slideArr.length);

	// for ( i in 0 ... slideArr.length ) {
	// 	var el : js.html.DivElement = cast(slideArr[i]);

	// 	map.set(el, false);

	// 	trace(new JQuery(el).offset(), new JQuery(el).height());

	// 	// trace(new JQuery('${slideArr[i]} img'));//.css({border:'2px solid pink'});
	// 	// trace(new JQuery(el).find('img').css({border:'2px solid pink'}));
	// 	// new JQuery(el).find('img').attr('src','https://dummyimage.com/3000x2000/0cf528/fff.jpg&text=test+image');


	// 	trace(new JQuery(el).find('img').attr('data-folder'));
	// 	trace(new JQuery(el).find('img').attr('data-img'));
	// }
*/

	static public function main () {
		var app = new Main ();
	}
}
