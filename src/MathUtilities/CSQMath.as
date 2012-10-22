package MathUtilities
{
	import MathUtilities.Functions.AbstractFunction;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;

	public class CSQMath
	{
		public function CSQMath()
		{
		}
		
		public static function distance(... args):Number {
			if(args[0] is Point) 
				return p2pDistance(args[0],args[1]);
			else if(args[0] is Number)
				return coord2coordDistance(args[0],args[1],args[2],args[3]);
			else if(args[0] is Vector2D)
				return v2vDistance(args[0],args[1]);
			else
				return 0;
		}
		
		private static function p2pDistance(p1:Point, p2:Point):Number {
			return coord2coordDistance(p1.x, p1.y, p2.x, p2.y);
		}
		
		private static function coord2coordDistance(x1:int, y1:int, x2:int, y2:int):Number {
			return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1,2));
		}
		
		private static function v2vDistance(v1:Vector2D, v2:Vector2D):Number {
			return coord2coordDistance(v1.x, v1.y, v2.x, v2.y);
		}
		
		// returns an angle from -180 to 180, starting at 0 on the positive x axis
		// and rotating clockwise for positive angles, v.v for negative ones
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):int {
			var angle:int = -Math.floor(Math.atan2(y2-y1,x2-x1)*180/Math.PI);
			//negative angles can be adjusted to make the range from 0 to 360
//			if(angle < 0) {
//				angle = 360 + angle;
//			}
			return -angle;
		}
		
		public static function equalWithin(a:Number, b:Number, error:Number):Boolean {
			return Math.abs(b - a) < error;
		}
		
		public static function sameSign(a:Number, b:Number):Boolean {
			return (a >= 0  && b >= 0) || (a <= 0 && b <= 0);
		}
		
		public static function roundTo(x:Number, n:int):Number {
			var result:Number = x * Math.pow(10, n);
			result = Math.round(result);
			result = result/Math.pow(10, n);
			return result;
		}
		
		public static function toRadians(x:Number):Number {
			return x/180*Math.PI;
		}
		
		public static function toDegrees(x:Number):Number {
			return x*180/Math.PI;
		}
		
		public static function getZeroArray(len:uint):Array {
			var zeroArray:Array = new Array(len);
			for(var i:uint = 0; i < len; i++) {
				zeroArray[i] = new Array(len);
				for(var j:uint = 0; j < len; j++) {
					zeroArray[i][j] = 0;
				}
			}
			return zeroArray;
		}
		
		public static function getAverageLocation(...points):Point {
			var result:Point = new Point(0,0);
			var len:uint = points.length;
			for(var i:uint = 0; i < len; i++) {
				result.x += points[i].x;
				result.y += points[i].y;
			}
			result.x /= len;
			result.y /= len;
			return result;
		}
	}
}