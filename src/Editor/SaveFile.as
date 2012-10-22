package Editor
{
	import MathUtilities.Vector2D;

	public class SaveFile
	{
		private var dataString:String;
		private var index:uint;
		private var dataArray:Vector.<Array>;
		private const words:Array = ["t","f","RigidBody","Disk","Ring","Polygon"];
		public var numObjects:uint;
		
		
		
		public function SaveFile(data:String)
		{
			this.dataString = data;
			index = 0;
			resolveData();
			numObjects = dataArray.length;
		}
		
		// returns an array of information used to recreate objects
		public function getObjectData(index:uint):Array {
			if(index >= numObjects)
				throw new Error("input greater than array length");
			
			return dataArray[index];
		}
		
		// Converts the input dataString into a vector of arrays which can be used to create objects.
		// First separates the string into a vector of strings with the "!" delimiter.
		// Then separates the each substring into an array of strings with the ";" delimiter.
		// Each individual string is converted into its original data type.
		private function resolveData():void {
			dataArray = new Vector.<Array>();
			var strings:Array = dataString.split("!");
			var len:uint = strings.length;
			// stop at 2 less than len since the strings[len-1] == "" if dataString ends in a '!'
			for(var i:uint = 0; i < len-1; i++) {
				dataArray.push((strings[i] as String).split(";"));
				var len2:uint = dataArray[i].length;
				for(var j:uint = 0; j < len2; j++) {
					interpretData(dataArray[i], j);
				}
			}
		}
		
		// Converts each piece of basic information,  
		private function interpretData(arr:Array, index:uint):void {
			var str:String = arr[index];
			if(words.indexOf(str) == -1) {
				if(str.indexOf(",") == -1) {
					var a:Number = readNumber(str);
					arr[index] = a;
				} else {
					var strings:Array = str.split(",",2);
					var x:Number = readNumber(strings[0] as String);
					var y:Number = readNumber(strings[1] as String);
					arr[index] = new Vector2D(x, y);
				}
			}
		}
		
		// Converts a string of digits into a number
		private function readNumber(str:String):Number {
			if(str.charAt(0) == "-") {
				var negative:Boolean = true;
				var startIndex:int = 1;
			} else {
				negative = false;
				startIndex = 0;
			}
			var decimalIndex:uint = 0;
			var result:Number = 0;
			var len:int = str.length-1;
			for(var i:int = len; i >= startIndex; i--) {
				if(str.charAt(i) == ".") {
					result /= Math.pow(10, len - i);
					decimalIndex = len - i + 1;
				} else {
					result += Math.pow(10, len - i - decimalIndex)*(str.charCodeAt(i) - 48);
				}
			}
			if(negative)
				result *= -1;
			return result;
		}
	}
}