package monk.core;

class Statics extends Content {

	private static var DEFAULT_ORDER:Int = 0;

	public var order(default, default) : Int = DEFAULT_ORDER;

	public override function parse(pathAndFileName:String) : String {
		var markdown:String = super.parse(pathAndFileName);
		this.order = getOrder(markdown);
		return markdown;
	}

	private static function getOrder(markdown:String) : Int {
		var counter = DEFAULT_ORDER;
		Statics.DEFAULT_ORDER++;
		return counter;
	}

	// don't need to inject metatdata in the statics
	private override function getAndGenerateId(fileName:String) : String {
		return '';
	}

}