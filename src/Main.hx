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

	var previousfromTop : Float = 0;
	var scrollUpCounter : Int = 0;

	public function new () {
		console.log('${App.MONK} version: ${App.VERSION}' );

		new JQuery(document).ready(function (e){
			console.log('${App.MONK} doc ready');
			if (new JQuery('body').hasClass('homepage')){
				isHomepage = true;
				initHomepage();
			} else {
				initParallax();
			}
		});

		new JQuery(window).resize(function (e){
			console.debug('resized');
			if(isHomepage){
				initHomepage();
			} else {
				initParallax();
			}
		});

		new JQuery(window).scroll(function (e){
			if(isHomepage){
				scrollHomepage();
			} else {
				scrollParallax();
			}
		});
	}

	function initHomepage(){
		divArr = [];
		divMap = new Map();
		var w = new JQuery(window).width();
		console.debug ('width: $w');
		new JQuery('.slide').each(function(i:Int,el:js.html.Element){
			divArr.push(js.Lib.nativeThis);
			divMap.set(js.Lib.nativeThis, false);
		});
		// [mck] start with first image
		updateHomepageImages(0, divArr[0]);
		// [mck] scroll homepage
		scrollHomepage();
	}

	function scrollHomepage(){
		var fromTop = new JQuery(document).scrollTop();
		var navHeight = new JQuery('nav').height();

		if(fromTop>navHeight) {
			new JQuery('.brand-name').addClass('brand-name-hide');
			new JQuery('#brand').addClass('brand-img-show');
			new JQuery('nav').addClass('hideup');
		}

		if(fromTop<navHeight) {
			new JQuery('.brand-name').removeClass('brand-name-hide');
			new JQuery('#brand').removeClass('brand-img-show');
			new JQuery('nav').removeClass('hideup');
		}

		// [mck] scroll up and show nav
		if (fromTop < previousfromTop){
			// [mck] TODO make this about distance not about times triggered
			var distance = previousfromTop - fromTop;
			// trace('upscroll code (${scrollUpCounter})');
			if(distance >= 100){
				trace('show brand');
				new JQuery('.brand-name').removeClass('brand-name-hide');
				new JQuery('#brand').removeClass('brand-img-show');
				new JQuery('nav').removeClass('hideup');
				// previousfromTop = fromTop;
			}
		}

		if(fromTop >= previousfromTop) {
			previousfromTop = fromTop;
		}

		// [mck] update image (homepage)
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
				updateHomepageImages(i,div);
			}
		}
	}

	function updateHomepageImages(id, div){
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

	function initParallax(){
		var padding = 0;
		var margin = 0;

		// [mck] there is a better way, but this is getting the job done right now!
		padding += Std.parseInt(new JQuery('.parallax-container').parent().css('padding-left'));
		padding += Std.parseInt(new JQuery('.parallax-container').parent().parent().css('padding-left'));
		padding += Std.parseInt(new JQuery('.parallax-container').parent().parent().parent().css('padding-left'));

		margin += Std.parseInt(new JQuery('.parallax-container').parent().css('margin-left'));
		margin += Std.parseInt(new JQuery('.parallax-container').parent().parent().css('margin-left'));
		margin += Std.parseInt(new JQuery('.parallax-container').parent().parent().parent().css('margin-left'));

		new JQuery('.parallax-container').css('left','-${padding+margin}px');
		new JQuery('.parallax-container').css('width','${new JQuery(window).width()}px');

		new JQuery('.parallax img').css({'display': 'block', "transform": "translate3d(-50%, 0px, 0px)"});

		// [mck] set data
		new JQuery('.parallax-container').attr('data-translate-y','0');

		scrollParallax();
	}

	function scrollParallax (){
		var fromTop = new JQuery(document).scrollTop();
		// [mck] parallax list
		var _arr = new JQuery('.parallax-container');
		for ( i in 0 ... _arr.length ){
			var containerHeight = new JQuery(_arr[i]).innerHeight();
			var containerOffset = new JQuery(_arr[i]).offset().top;
			var containerHeight = new JQuery(_arr[i]).height();
			var imageHeight = new JQuery(_arr[i]).find('.parallax img').height();

			// [mck] make sure there is an height to work with
			if(imageHeight == 0) {
				haxe.Timer.delay(scrollParallax, 100);
				return;
			}

			var maxMove = (containerOffset+containerHeight)-(containerOffset-window.innerHeight);
			var currentMove = (fromTop-(containerOffset-window.innerHeight));
			var percentage = (currentMove/maxMove);
			var maxImageMove = (imageHeight - containerHeight);

			// new JQuery(_arr[i]).attr('data-container-top','${containerOffset-window.innerHeight}');
			// new JQuery(_arr[i]).attr('data-container-bottom','${containerOffset+containerHeight}');
			// new JQuery(_arr[i]).attr('data-container-fromtop','${fromTop}');
			// new JQuery(_arr[i]).attr('data-container-max','${maxMove}');
			// new JQuery(_arr[i]).attr({'data-percentage':percentage});

			// check for visible part
			if(fromTop <= containerOffset + containerHeight && fromTop + window.innerHeight >= containerOffset){
				if(new JQuery(_arr[i]).hasClass('parallax-not-visible')){
					new JQuery(_arr[i]).removeClass('parallax-not-visible');
				}
				new JQuery(_arr[i]).addClass('parallax-visible');
			} else {
				if(new JQuery(_arr[i]).hasClass('parallax-visible')){
					new JQuery(_arr[i]).removeClass('parallax-visible');
				}
				new JQuery(_arr[i]).addClass('parallax-not-visible');
			}

			// [mck] only when visible
			if(new JQuery(_arr[i]).hasClass('parallax-visible')){
				// [mck] calculate the number of movement
				var ypos = maxImageMove * percentage;
				new JQuery(_arr[i]).find('.parallax img').css({'transform': 'translate3d(-50%, ${ypos}px, 0px)'});
			}
		}
	}





	static public function main () { var app = new Main (); }
}
