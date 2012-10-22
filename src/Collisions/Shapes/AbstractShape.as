package Collisions.Shapes
{
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class AbstractShape extends MovieClip
	{
		public var density:Number = 0.01;
		public var mass:Number;
		public var center:Vector2D;
		public var color:uint;
		public var vertices:Vector.<Vector2D>;
		public var nextVertices:Vector.<Vector2D>;
		// container for the depth graphics
		public var depthSprite:Sprite;
		// determines whether or not the body is depicted in 2.5D (with depth)
		public var depth:Number;
		public var horizon:Vector2D;
		
		public function AbstractShape(center:Vector2D, mass:Number, color:uint)
		{
			vertices = new Vector.<Vector2D>();
			this.center = center;
			this.mass = mass;
			this.color = color;
		}
		
		public function calculateMomentOfInertia():Number { return 0; }
		
		public function drawVertices():void {}
		
		public function translate(displacement:Vector2D):void {}

		public function rotateAround(radians:Number, axis:Vector2D=null):void {
			for each(var v:Vector2D in vertices) {
				v.rotate(radians);
			}
			center.rotate(radians);
//			if(axis != null) {
//				var p:Vector2D = center.copy();
//				p.subtract(axis);
//				var pcopy:Vector2D = p.copy();
//				pcopy.rotate(radians);
//				pcopy.subtract(p);
//				translate(pcopy);
//			}
		}
		
		// calculates the vertices of the Shape in the next frame assuming no collision occurs
		// also adds in the center of the object (used more often in this form)
		public function calculateNextVertices(offset:Vector2D, velocity:Vector2D, angularVelocity:Number):void {
			nextVertices = new Vector.<Vector2D>();
			var len:uint = vertices.length;
			for(var i:uint = 0; i < len; i++) {
				var v:Vector2D = vertices[i].copy();
				v.rotate(angularVelocity);
				v.add(offset);
				v.add(velocity);
				nextVertices.push(v);
			}
		}
		
		// projects the rigid body onto the parameter axis vertex by vertex
		public function project(axis:Vector2D):Vector.<Interval> { return null }
		
		public function findMaxRadius():Number { return 0 }
		
		public function setHorizon(v:Vector2D):void {
			horizon = v;
		}
		
		public function roundValues():void {}
		
		public function exportData():String { return null }
		
		override public function toString():String {
			return "Shape centered at " + center.toString();
		}
	}
}