// Generated by Haxe 3.4.2
(function () { "use strict";
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
var Main = function() {
	this.previousfromTop = 0;
	this.isHomepage = false;
	this.divMap = new haxe_ds_ObjectMap();
	this.divArr = [];
	var _gthis = this;
	window.console.log("MONK" + " version: " + "0.0.8");
	$(window.document).ready(function(e) {
		window.console.log("MONK" + " doc ready");
		if($("body").hasClass("homepage")) {
			_gthis.isHomepage = true;
			_gthis.initHomepage();
		} else {
			_gthis.initParallax();
		}
	});
	$(window).resize(function(e1) {
		window.console.debug("resized");
		if(_gthis.isHomepage) {
			_gthis.initHomepage();
		} else {
			_gthis.initParallax();
		}
	});
	$(window).scroll(function(e2) {
		if(_gthis.isHomepage) {
			_gthis.scrollHomepage();
		} else {
			_gthis.scrollParallax();
		}
	});
};
Main.__name__ = true;
Main.main = function() {
	var app = new Main();
};
Main.prototype = {
	initParallax: function() {
		var padding = 0;
		var margin = 0;
		padding += Std.parseInt($(".parallax-container").parent().css("padding-left"));
		padding += Std.parseInt($(".parallax-container").parent().parent().css("padding-left"));
		padding += Std.parseInt($(".parallax-container").parent().parent().parent().css("padding-left"));
		margin += Std.parseInt($(".parallax-container").parent().css("margin-left"));
		margin += Std.parseInt($(".parallax-container").parent().parent().css("margin-left"));
		margin += Std.parseInt($(".parallax-container").parent().parent().parent().css("margin-left"));
		$(".parallax-container").css("left","-" + (padding + margin) + "px");
		$(".parallax-container").css("width","" + $(window).width() + "px");
		$(".parallax img").css({ "display" : "block", "transform" : "translate3d(-50%, 0px, 0px)"});
		$(".parallax-container").attr("data-translate-y","0");
		this.scrollParallax();
	}
	,initHomepage: function() {
		var _gthis = this;
		this.divArr = [];
		this.divMap = new haxe_ds_ObjectMap();
		var w = $(window).width();
		window.console.debug("width: " + w);
		$(".slide").each(function(i,el) {
			_gthis.divArr.push(this);
			_gthis.divMap.set(this,false);
		});
		this.updateImage(0,this.divArr[0]);
		this.scrollHomepage();
	}
	,scrollParallax: function() {
		var fromTop = $(window.document).scrollTop();
		var _arr = $(".parallax-container");
		var _g1 = 0;
		var _g = _arr.length;
		while(_g1 < _g) {
			var i = _g1++;
			var containerHeight = $(_arr[i]).innerHeight();
			var containerOffset = $(_arr[i]).offset().top;
			var containerHeight1 = $(_arr[i]).height();
			var imageHeight = $(_arr[i]).find(".parallax img").height();
			var maxMove = containerOffset + containerHeight1 - (containerOffset - window.innerHeight);
			var currentMove = fromTop - (containerOffset - window.innerHeight);
			var percentage = currentMove / maxMove;
			var maxImageMove = imageHeight - containerHeight1;
			if(fromTop <= containerOffset + containerHeight1 && fromTop + window.innerHeight >= containerOffset) {
				if($(_arr[i]).hasClass("parallax-not-visible")) {
					$(_arr[i]).removeClass("parallax-not-visible");
				}
				$(_arr[i]).addClass("parallax-visible");
			} else {
				if($(_arr[i]).hasClass("parallax-visible")) {
					$(_arr[i]).removeClass("parallax-visible");
				}
				$(_arr[i]).addClass("parallax-not-visible");
			}
			if($(_arr[i]).hasClass("parallax-visible")) {
				var ypos = maxImageMove * percentage;
				$(_arr[i]).find(".parallax img").css({ "transform" : "translate3d(-50%, " + ypos + "px, 0px)"});
			}
		}
	}
	,scrollHomepage: function() {
		var fromTop = $(window.document).scrollTop();
		var navHeight = $("nav").height();
		if(fromTop > navHeight) {
			$(".brand-name").addClass("brand-name-hide");
			$("#brand").addClass("brand-img-show");
			$("nav").addClass("hideup");
		}
		if(fromTop < navHeight) {
			$(".brand-name").removeClass("brand-name-hide");
			$("#brand").removeClass("brand-img-show");
			$("nav").removeClass("hideup");
		}
		if(fromTop < this.previousfromTop) {
			var distance = this.previousfromTop - fromTop;
			if(distance >= 100) {
				console.log("show brand");
				$(".brand-name").removeClass("brand-name-hide");
				$("#brand").removeClass("brand-img-show");
				$("nav").removeClass("hideup");
			}
		}
		if(fromTop >= this.previousfromTop) {
			this.previousfromTop = fromTop;
		}
		var _g1 = 0;
		var _g = this.divArr.length;
		while(_g1 < _g) {
			var i = _g1++;
			var div = this.divArr[i];
			var isDone = this.divMap.h[div.__id__];
			if(isDone) {
				continue;
			}
			var imgOffset = $(div).offset().top;
			var imgHeight = $(div).height();
			var imgBottomOffset = imgOffset + imgHeight;
			if(fromTop >= imgOffset && fromTop < imgBottomOffset) {
				this.updateImage(i,div);
			}
		}
	}
	,updateImage: function(id,div) {
		this.divMap.set(div,true);
		if(id + 1 > this.divArr.length) {
			return;
		}
		var _arr = [div,this.divArr[id + 1]];
		var _g1 = 0;
		var _g = _arr.length;
		while(_g1 < _g) {
			var i = _g1++;
			var _div = _arr[i];
			var folderSizeName = Std.string(monk_model_constants_App.photoFileSizeArray[monk_model_constants_App.photoFileSizeArray.length - 1]);
			var w = $(window).width();
			var _g3 = 0;
			var _g2 = monk_model_constants_App.photoFileSizeArray.length;
			while(_g3 < _g2) {
				var i1 = _g3++;
				var value = monk_model_constants_App.photoFileSizeArray[i1];
				if(w <= value) {
					if(value == null) {
						folderSizeName = "null";
					} else {
						folderSizeName = "" + value;
					}
				}
			}
			var dataFolder = $(_div).find("img").attr("data-folder");
			var dataImg = $(_div).find("img").attr("data-img");
			if(window.location.href.indexOf(dataFolder) != -1) {
				var img = $(_div).find("img").attr("src","" + folderSizeName + "/" + dataImg);
			} else {
				var img1 = $(_div).find("img").attr("src","" + dataFolder + "/" + folderSizeName + "/" + dataImg);
			}
		}
	}
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) {
		v = parseInt(x);
	}
	if(isNaN(v)) {
		return null;
	}
	return v;
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
var haxe_ds_ObjectMap = function() {
	this.h = { __keys__ : { }};
};
haxe_ds_ObjectMap.__name__ = true;
haxe_ds_ObjectMap.__interfaces__ = [haxe_IMap];
haxe_ds_ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe_ds_ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) {
					return o[0];
				}
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) {
						str += "," + js_Boot.__string_rec(o[i],s);
					} else {
						str += js_Boot.__string_rec(o[i],s);
					}
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g11 = 0;
			var _g2 = l;
			while(_g11 < _g2) {
				var i2 = _g11++;
				str1 += (i2 > 0 ? "," : "") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) {
			str2 += ", \n";
		}
		str2 += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var monk_model_constants_App = function() { };
monk_model_constants_App.__name__ = true;
String.__name__ = true;
Array.__name__ = true;
haxe_ds_ObjectMap.count = 0;
monk_model_constants_App.photoFileSizeArray = [3840,2560,1920,1280,1024,640];
Main.main();
})();
