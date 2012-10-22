package Collisions.Shapes
{
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;
	import MathUtilities.CSQMath;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	public class Ring extends AbstractShape
	{
		public var innerRadius:Number;
		public var outerRadius:Number;
		
		public function Ring(center:Vector2D, innerRadius:Number, outerRadius:Number, mass:Number, 
								color:uint)
		{
			super(center, mass, color);
			this.innerRadius = innerRadius;
			this.outerRadius = outerRadius;
			vertices.push(center);
			drawVertices();
		}
		
		override public function calculateMomentOfInertia():Number {
			if(mass == 0)
				mass = Math.PI * Math.pow(outerRadius, 2) * density;
			return 0.5 * mass * (Math.pow(outerRadius, 2) - Math.pow(innerRadius, 2));
		}
		
		override public function project(axis:Vector2D):Vector.<Interval> {
			var axisCopy:Vector2D = axis.isUnitVector() ? axis.copy() : axis.unitVector();
			var temp:Number = nextVertices[0].dot(axisCopy);
			var result:Vector.<Interval> = new Vector.<Interval>();
			result.push(new Interval(temp - outerRadius, temp - innerRadius), 
				new Interval(temp + innerRadius, temp + outerRadius));
			return result;
		}
		
		override public function findMaxRadius():Number {
			return center.magnitude() + outerRadius;
		}
		
		override public function drawVertices():void {
			graphics.beginFill(color);
			graphics.lineStyle(1);
			graphics.drawCircle(center.x, center.y, outerRadius);
			graphics.beginFill(0xffffff,0.5);
			graphics.drawCircle(center.x, center.y, innerRadius);
			graphics.moveTo(center.x, center.y + innerRadius);
			graphics.lineTo(center.x, center.y + outerRadius);
		}
		
		override public function exportData():String {
			var result:String = "Ring;";
			result += center.x+"," + center.y+";" ;
			result += innerRadius+";" + outerRadius+";" + mass+";" + color+"!";
			return result;
		}
		
		override public function roundValues():void {
			center.x = CSQMath.roundTo(center.x, 2);
			center.y = CSQMath.roundTo(center.y, 2);
			innerRadius = CSQMath.roundTo(innerRadius, 2);
			outerRadius = CSQMath.roundTo(outerRadius, 2);
			mass = CSQMath.roundTo(mass, 2);
		}
		
		override public function toString():String {
			return "Disk with centered at " + center.toString();
		}
	}
}