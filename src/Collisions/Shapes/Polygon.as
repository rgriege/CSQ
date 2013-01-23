package Collisions.Shapes
{	
	import MathUtilities.CSQMath;
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;
	
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;

	public class Polygon extends AbstractShape
	{
		// stores the number of non-parallel edges, used in the collidesWith method
		public var numDistinctAxes:uint;
		// stores whether or not the vertices are defined counter-clockwise
		private var definedCCW:Boolean;
		
		public function Polygon(center:Vector2D, vertices:Vector.<Vector2D>, mass:Number, color:uint)
		{
			super(center, mass, color);
			this.vertices = vertices;
//			addVerticesFromArray(vertices);
			checkNumVertices();
			recalculateVertices();
			checkConvex();
			adjustNumDistinctAxes();
		}
		
		// Shapes are defined by a series of vertices.
		// Input should be received in the format (x1, y1, x2, y2, ...) unless creating a circle,
		// in which case the format is (x1, y1, radius)
		private function addVerticesFromArray(vectors:Array):void {			
			vertices = new Vector.<Vector2D>();
			var len:uint = vectors.length;
			for(var i:uint = 0; i < len; i++) {
				vertices.push((vectors[i] as Vector2D).copy());
			}
		}
		
		// throws an error if there are less than 3 vertices
		private function checkNumVertices():void {
			// there must be more than 3 vertices to make a polygon
			if(vertices.length < 3 && vertices.length != 1)
				throw new Error("A polygon must have at least 3 vertices, and a circle only has 1.");
		}
		
		// Recalculates the vertices as vectors from the center of mass to the corners;
		// adjusts these new vertices according to the new center
		private function recalculateVertices():void {
			var change:Vector2D = center.copy();
			var currentCenter:Vector2D = new Vector2D(0,0);
			for each(var v:Vector2D in vertices) {
				currentCenter.add(v);
			}
			currentCenter.scale(1/vertices.length);
			change.subtract(currentCenter);
			for each(v in vertices) {
				v.add(change);
			}
		}
		
		// throws an error if the polygon is not convex
		private function checkConvex():void {
			var prevAxisPerp:Vector2D = vertices[1].copy();
			prevAxisPerp.subtract(vertices[0]);
			prevAxisPerp = prevAxisPerp.getPerpendicular();
			var curAxis:Vector2D = vertices[2].copy();
			curAxis.subtract(vertices[1]);
			definedCCW = curAxis.dot(prevAxisPerp) >= 0;
			var len:uint = vertices.length;
			for(var i:uint = 3; i < len; i++) {
				prevAxisPerp = curAxis.getPerpendicular(definedCCW);
				curAxis = vertices[i].copy();
				curAxis.subtract(vertices[i-1]);
				if(curAxis.dot(prevAxisPerp) < 0)
					throw new Error("not convex");
			}
			prevAxisPerp = curAxis.getPerpendicular(definedCCW);
			curAxis = vertices[0].copy();
			curAxis.subtract(vertices[len-1]);
			if(curAxis.dot(prevAxisPerp) < 0)
				throw new Error("not convex");
			return;
		}
		
		// sets the numDistinctAxes variable based on how many non-parallel edges exist
		// this data is used in the collidesWith method
		private function adjustNumDistinctAxes():void {
			var axes:Vector.<Vector2D> = new Vector.<Vector2D>();
			for(var i:uint = 0; i < vertices.length; i++) {
				var edge:Vector2D = (i < vertices.length - 1) ? vertices[i+1].copy() : vertices[0].copy();
				edge.subtract(vertices[i]);
				edge = edge.unitVector();
				var add:Boolean = true;
				for each(var vec:Vector2D in axes) {
					if(vec.equals(edge) || vec.equals(edge.invert()))
						add = false;
				}
				if(add)
					axes.push(edge);
			}
			numDistinctAxes = axes.length;
		}
		
		// calculate and return the moment of inertia
		override public function calculateMomentOfInertia():Number {
			var area:Number = 0;
			var numerator:Number = 0;
			var denominator:Number = 0;
			var len:uint = vertices.length;
			for(var i:uint = 0; i < len; i++) {
				var temp:Vector2D = vertices[i].unitVector().getPerpendicular();
				var nextVertex:Vector2D = (i < len-1 ? vertices[i+1] : vertices[0]);
				var height:Number = Math.abs(nextVertex.dot(temp));
				var crossProduct:Number = vertices[i].magnitude()*height;
				area += 0.5*crossProduct;
				numerator += crossProduct*(nextVertex.dot(nextVertex) + nextVertex.dot(vertices[i]) + 
					vertices[i].dot(vertices[i]));
				denominator += crossProduct;
			}
			if(mass == 0)
				mass = area * density;
			return mass/6*numerator/denominator;
		}
		
		override public function getSeparatingAxes(s:AbstractShape):Vector.<Vector2D> {
			var result:Vector.<Vector2D> = new Vector.<Vector2D>();
			var len:uint = nextVertices.length;
			for(var i:uint = 0; i < len; i++) {
				var edge:Vector2D = (i < len - 1) ? nextVertices[i+1].copy() : nextVertices[0].copy();
				edge.subtract(nextVertices[i]);
				var axis:Vector2D = edge.getPerpendicular().unitVector();
				result.push(axis);
			}
			return result;
		}
		
		// Instead of projecting the actual vertices, we project copies of them that
		// have the velocity added in, thus detecting collisions before they happen.
		override public function project(axis:Vector2D):Interval {
			var axisCopy:Vector2D = axis.isUnitVector() ? axis.copy() : axis.unitVector();
			var projection:Interval = new Interval(nextVertices[0].dot(axisCopy), nextVertices[0].dot(axisCopy));
			var len:uint = vertices.length;
			for(var i:uint = 1; i < len; i++) {
				var temp:Number = nextVertices[i].dot(axis);
				projection.leftLimit = (temp < projection.leftLimit) ? temp : projection.leftLimit;
				projection.rightLimit = (temp > projection.rightLimit) ? temp : projection.rightLimit;
			}
			return projection;
		}
		
		override public function findMaxRadius():Number {
			var result:Number = 0;
			for each(var v:Vector2D in vertices) {
				var temp:Vector2D = v.copy();
				temp.add(center);
				var distance:Number = temp.magSquared();
				if(distance > result)
					result = distance;
			}
			return Math.sqrt(result);
		}
		
		override public function drawVertices():void {
			graphics.beginFill(color,0.7);
			graphics.lineStyle(1);
			var len:uint = vertices.length;
			graphics.moveTo(vertices[len-1].x, vertices[len-1].y);
			for(var i:uint = 0; i < len; i++) {
				graphics.lineTo(vertices[i].x, vertices[i].y);
			}
		}
		
		private function drawDepthSprite():void {
			removeChild(depthSprite);
			depthSprite = new Sprite();
			var depthVertices:Vector.<Vector2D> = calculateDepthVertices();
			drawDepthVertices(depthVertices);
			addChild(depthSprite);
		}
		
		private function calculateDepthVertices():Vector.<Vector2D> {
			var result:Vector.<Vector2D> = new Vector.<Vector2D>();
			var len:uint = vertices.length;
			var count:uint = 1;
			var prevEdgePerp:Vector2D = vertices[0].copy();
			prevEdgePerp.subtract(vertices[len-1]);
			prevEdgePerp = prevEdgePerp.getPerpendicular(definedCCW);
			var nextEdgePerp:Vector2D = vertices[1].copy();
			nextEdgePerp.subtract(vertices[0]);
			nextEdgePerp = nextEdgePerp.getPerpendicular(definedCCW);
			for(var i:uint = 0; i < len; i++) {
				var depthVertex:Vector2D = horizon.copy();
				depthVertex.subtract(center);
				depthVertex.subtract(vertices[i]);
				depthVertex = depthVertex.unitVector();
				depthVertex.scale(depth);
				if(depthVertex.dot(prevEdgePerp) < 0 || depthVertex.dot(nextEdgePerp) < 0) {
					depthVertex.add(vertices[i]);
					if(count == 1)
						result.push(vertices[i],depthVertex,depthVertex,vertices[i]);
					else {
						result.splice(count,0,vertices[i],depthVertex,depthVertex,vertices[i]);
						count += 4;
					}
				} else if(result.length != 0)
					count = 0;
				prevEdgePerp = nextEdgePerp;
				nextEdgePerp = vertices[i+2 < len ? i+2 : i-len+2].copy();
				nextEdgePerp.subtract(vertices[i+1 < len ? i+1 : 0]);
				nextEdgePerp = nextEdgePerp.getPerpendicular(definedCCW);
			}
			result.pop();
			result.pop();
			result.splice(0,2);
			return result;
		}
		
		private function drawDepthVertices(dvs:Vector.<Vector2D>):void {
			depthSprite.graphics.clear();
			depthSprite.graphics.lineStyle(1);
			depthSprite.graphics.beginFill(color);
			var len:uint = dvs.length;
			for(var i:uint = 0; i < len; i++) {
				if(i % 4 == 0)
					depthSprite.graphics.moveTo(dvs[i+3].x, dvs[i+3].y);
				depthSprite.graphics.lineTo(dvs[i].x, dvs[i].y);
			}
		}
		
		override public function exportData():String {
			var result:String = "Polygon;";
			result += center.x+"," + center.y+";" ;
			for each(var v:Vector2D in vertices) {
				result += v.x+"," + v.y+";";
			}
			result += mass+";" + color+"!";
			return result;
		}
		
		override public function roundValues():void {
			center.x = CSQMath.roundTo(center.x, 2);
			center.y = CSQMath.roundTo(center.y, 2);
			for each(var v:Vector2D in vertices) {
				v.x = CSQMath.roundTo(v.x, 2);
				v.y = CSQMath.roundTo(v.y, 2);
			}
			mass = CSQMath.roundTo(mass, 2);
		}
		
		override public function toString():String {
			return "Polygon with centered at " + center.toString();
		}
	}
}