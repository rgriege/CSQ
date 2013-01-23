package Collisions.Shapes
{
	import MathUtilities.CSQMath;
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;

	public class Disk extends AbstractShape
	{
		public var radius:Number;
		
		public function Disk(center:Vector2D, radius:Number, mass:Number, color:uint)
		{
			super(center, mass, color);
			vertices.push(center);
			this.radius = radius;
			drawVertices();
		}
		
		override public function calculateMomentOfInertia():Number {
			if(mass == 0)
				mass = Math.PI * Math.pow(radius, 2) * density;
			return 0.5 * mass * Math.pow(radius, 2);
		}
		
		override public function getSeparatingAxes(s:AbstractShape):Vector.<Vector2D> {
			var result:Vector2D = s.center.copy();
			result.subtract(nextVertices[0]);
			var vr:Vector.<Vector2D> = new Vector.<Vector2D>();
			vr.push(result);
			return vr;
		}
		
		override public function project(axis:Vector2D):Interval {
			var axisCopy:Vector2D = axis.isUnitVector() ? axis.copy() : axis.unitVector();
			var temp:Number = nextVertices[0].dot(axisCopy);
			return new Interval(temp - radius, temp + radius);
		}
		
		override public function findMaxRadius():Number {
			return center.magnitude() + radius;
		}
		
		override public function drawVertices():void {
			graphics.beginFill(color);
			graphics.lineStyle(1);
			graphics.drawCircle(center.x, center.y, radius);
			graphics.moveTo(center.x, center.y);
			graphics.lineTo(center.x, center.y + radius);
		}
		
		override public function exportData():String {
			var result:String = "Disk;";
			result += center.x+"," + center.y+";" ;
			result += radius+";" + mass+";" + color+"!";
			return result;
		}
		
		override public function roundValues():void {
			center.x = CSQMath.roundTo(center.x, 2);
			center.y = CSQMath.roundTo(center.y, 2);
			radius = CSQMath.roundTo(radius, 2);
			mass = CSQMath.roundTo(mass, 2);
		}
		
		override public function toString():String {
			return "Circle centered at " + center.toString();
		}
	}
}