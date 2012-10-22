package Collisions
{
	import Collisions.Shapes.AbstractShape;
	import Collisions.Shapes.Disk;
	import Collisions.Shapes.Polygon;
	import Collisions.Shapes.Ring;
	
	import DataStructures.Integer;
	
	import MathUtilities.CSQMath;
	import MathUtilities.Functions.TrigFunction;
	import MathUtilities.Interval;
	import MathUtilities.Vector2D;

	public class ShapePenetration
	{
		public var rb1:RigidBody;
		public var rb2:RigidBody;
		public var s1:AbstractShape;
		public var s2:AbstractShape;
		private var rb1nextCenter:Vector2D;
		private var rb2nextCenter:Vector2D;
		// vector from the center of rb1 to the center of rb2
		private var c2cVec:Vector2D;
		// boolean storing whether or not the AABB's of the Rigid Bodies overlap
		private var close:Boolean;
		// vector of all the possible axes of a collision
		public var possibleAxes:Vector.<Vector2D>;
		// a unit vector in the direction of the minimum overlap, always points from
		// rb1 to rb2
		public var collisionAxis:Vector2D;
		// stores true if the collisionAxis is found from an rb1 edge's normal
		public var axisFromS1:Boolean;
		// collisionAxis scaled by the overlap distance
		public var collisionVector:Vector2D = new Vector2D(0,0);
		public var penetrationTime:Number;
		// the point at which the two bodies first collide
		public var impactVector:Vector2D;
		// the vectors from the centers of Rigid Bodies 1 & 2 to the impact vector
		public var radius1:Vector2D;
		public var radius2:Vector2D;
		// stores the relative velocity of the point of impact, found by subtracting rb1's velocity
		// from rb2's velocity
		public var ipv:Vector2D;
		
		public function ShapePenetration(rb1:RigidBody, s1:AbstractShape, rb2:RigidBody, s2:AbstractShape)
		{
			this.rb1 = rb1;
			this.s1 = s1;
			this.rb2 = rb2;
			this.s2 = s2;
			
			rb1nextCenter = rb1.center.copy();
			rb1nextCenter.add(rb1.velocity);
			rb2nextCenter = rb2.center.copy();
			rb2nextCenter.add(rb2.velocity);
			c2cVec = rb2nextCenter.copy();
			c2cVec.subtract(rb1nextCenter);
			
			/* Determine whether AABB's of both Rigid Bodies intersect. This
			is a much, much cheaper calculation than the rigorous method that
			follows, and most of the time two objects are not colliding. */
			
			close = boundsOverlap();
			if(close) {
				possibleAxes = findPossibleAxes();
				collisionVector = findCollisionVector();
				
				// Make sure the rigorous test came back positive, then continue
				
				if(!collisionVector.isZero()) {
					moveNextVerticesToTangency();
					impactVector = findImpactVector();
					findRadii();
					findIPV();
				}
			}
		}
		
		// returns true if the AABB's of s1 and s2 overlap
		private function boundsOverlap():Boolean {
			if(s1 is Polygon && s2 is Polygon)
				return Interval.Inclusion(s1.project(Vector2D.X_AXIS)).overlapDistance(
					Interval.Inclusion(s2.project(Vector2D.X_AXIS))) && 
					   Interval.Inclusion(s1.project(Vector2D.Y_AXIS)).overlapDistance(
					Interval.Inclusion(s2.project(Vector2D.Y_AXIS)));
			else
				return true;
		}
		
		public function exists():Boolean {
			return close && !collisionVector.isZero();
		}
		
		// returns all the possible axes of the collision, which are the unit vectors
		// perpendicular to each edge of the Rigid Body
		private function findPossibleAxes():Vector.<Vector2D> {			
			var result:Vector.<Vector2D> = new Vector.<Vector2D>();
			if(s1 is Polygon) {
				result = (s1 as Polygon).findEdgePerpendiculars();
			} else {
				if(s1 is Disk)
					var temp:Vector2D = findClosestVertex(s1.nextVertices[0], s2.nextVertices);
				else
					temp = findFurthestVertex(s1.nextVertices[0], s2.nextVertices);
				temp.subtract(s1.nextVertices[0]);
				temp = temp.unitVector();
				result.push(temp);
			}
			if(s2 is Polygon)
				result = result.concat((s2 as Polygon).findEdgePerpendiculars());
			else {
				if(s1 is Disk)
					temp = findClosestVertex(s2.nextVertices[0], s1.nextVertices);
				else
					temp = findFurthestVertex(s2.nextVertices[0], s1.nextVertices);
				temp.subtract(s2.nextVertices[0]);
				temp.invert();
				temp = temp.unitVector();
				result.push(temp);
			}
			// check the axes against the center-to-center vector. The two should share the same
			// quadrant: that way, the axis always points from rb1 to rb2
			var len:uint = result.length;
			if((s1 is Ring) == (s2 is Ring)) {
				for(var i:uint = 0; i < len; i++) {
					if(result[i].dot(c2cVec) < 0)
						result[i] = result[i].invert();
				}
			} else {
				for(i = 0; i < len; i++) {
					if(result[i].dot(c2cVec) > 0)
						result[i] = result[i].invert();
				}
			}
			// not used to ensure the axisFromRb1 variable is correct; probably doesn't improve efficiency
			//			removeDuplicates(result);
			return result;
		}
		
		private function findClosestVertex(point:Vector2D, vertices:Vector.<Vector2D>):Vector2D {
			var len:uint = vertices.length;
			var min:Number = Math.pow(point.x - vertices[0].x, 2) + Math.pow(point.y - vertices[0].y, 2);
			var result:Vector2D = vertices[0].copy();
			for(var i:uint = 1; i < len; i++) {
				var dist:Number = Math.pow(point.x-vertices[i].x, 2) + Math.pow(point.y-vertices[i].y, 2);
				if(dist < min) {
					min = dist;
					result = vertices[i].copy();
				}
			}
			return result;
		}
		
		private function findFurthestVertex(point:Vector2D, vertices:Vector.<Vector2D>):Vector2D {
			var len:uint = vertices.length;
			var min:Number = 0;
			var result:Vector2D;
			for(var i:uint = 0; i < len; i++) {
				var dist:Number = Math.pow(point.x-vertices[i].x, 2) + Math.pow(point.y-vertices[i].y, 2);
				if(dist > min) {
					min = dist;
					result = vertices[i].copy();
				}
			}
			return result;
		}
		
		private function removeDuplicates(arr:Vector.<Vector2D>):void {
			var len:int = arr.length;
			for(var i:int = len-1; i >= 1; i--) {
				for(var j:int = i-1; j >= 0; j--) {
					if(arr[i].equals(arr[j])) {
						arr.splice(j, 1);
						i--;
					}
				}
			}
		}
		
		private function findCollisionVector():Vector2D {			
			var minOverlap:Number = 0;
			collisionAxis = new Vector2D(0, 0);
			var len:uint = possibleAxes.length;
			var index:uint = 0;
			for(var i:uint = 0; i < len; i++) {
				var projectionOverlap:Number = findOverlapAlongAxis(s1, s2, possibleAxes[i]);;
				if(projectionOverlap == 0 && !(s1 is Ring) && !(s2 is Ring)) {
					return new Vector2D(0, 0);
				} else if((projectionOverlap < minOverlap && projectionOverlap != 0) || minOverlap == 0) {
					minOverlap = projectionOverlap;
					collisionAxis = possibleAxes[i];
					index = i;
				}
			}
			axisFromS1 = (index < s1.nextVertices.length);
			var temp:Vector2D = collisionAxis.copy();
			temp.scale(minOverlap);
			return temp;
		}
		
		private function findOverlapAlongAxis(shape1:AbstractShape, shape2:AbstractShape, 
											  axis:Vector2D):Number {
			var overlapAlongAxis:Number = 0;
			var vi1:Vector.<Interval> = shape1.project(axis);
			var vi2:Vector.<Interval> = shape2.project(axis);
			for each(var i1:Interval in vi1) {
				for each(var i2:Interval in vi2) {
					var overlap:Number = i1.overlapDistance(i2);
					if(overlap != 0)
						overlapAlongAxis = overlap;
				}
			}
			return overlapAlongAxis;
		}
		
		/* The distance of minimum overlap is equal to the difference of the two velocities
		projected onto the overlap axis and then multiplied by a time (x = v*t). By solving
		this equation for time, the bodies can be moved backwards to the point of tangency.*/
		private function moveNextVerticesToTangency():void {
			var timeChange:Number = 0.5
			var timeToPenetration:Number = 0.5;
			var axis:Vector2D = collisionAxis.copy();
			var overlapping:Boolean = false;
			while(timeChange > 0.01 || !overlapping) {
				var vel1:Vector2D = rb1.velocity.copy();
				vel1.scale(timeToPenetration);
				var vel2:Vector2D = rb2.velocity.copy();
				vel2.scale(timeToPenetration);
				s1.calculateNextVertices(rb1.center, vel1, rb1.angularVelocity*timeToPenetration);
				s2.calculateNextVertices(rb2.center, vel2, rb2.angularVelocity*timeToPenetration);
				if(axisFromS1)
					axis.rotate(rb1.angularVelocity*timeToPenetration);
				else
					axis.rotate(rb2.angularVelocity*timeToPenetration);
				timeChange /= 2;
				overlapping = findOverlapAlongAxis(s1, s2, axis) > 0;
				if(overlapping)
					timeToPenetration -= timeChange;
				else
					timeToPenetration += timeChange;
			}
			penetrationTime = 1 - timeToPenetration;
		}
		
		// returns the vector of the point of impact, i.e., the point at which the
		// collision forces will act
		private function findImpactVector():Vector2D {
			// if the collision involves a circle, the calculation is much simpler
			if(!(s1 is Polygon)) {
				var quickResult:Vector2D = s1.nextVertices[0].copy();
				var temp:Vector2D = collisionAxis.copy();
				if(s1 is Disk)
					temp.scale((s1 as Disk).radius);
				else {
					if(c2cVec.magSquared() < Math.pow((s1 as Ring).innerRadius, 2))
						temp.scale(-(s1 as Ring).innerRadius);
					else
						temp.scale((s1 as Ring).outerRadius);
				}
				quickResult.add(temp);
				return quickResult;
			}
			if(!(s2 is Polygon)) {
				quickResult = s2.nextVertices[0].copy();
				temp = collisionAxis.copy();
				if(s2 is Disk)
					temp.scale(-(s2 as Disk).radius);
				else {
					if(c2cVec.magSquared() < Math.pow((s1 as Ring).innerRadius, 2))
						temp.scale((s2 as Ring).innerRadius);
					else
						temp.scale(-(s2 as Ring).outerRadius);
				}
				quickResult.add(temp);
				return quickResult;
			}
			
			// now check for edge-vertex collisions, the next simplest
			var leadingVertices:Vector.<Vector2D>;
			if(axisFromS1) {
				var goal:Vector2D = s1.center.copy();
				goal.add(rb1.center);
				leadingVertices = findClosestVerticesAlongAxis(s2.nextVertices, goal, collisionAxis);
			} else {
				goal = s2.center.copy();
				goal.add(rb2.center);
				leadingVertices = findClosestVerticesAlongAxis(s1.nextVertices, goal, collisionAxis);
			}
			if(leadingVertices.length == 1)
				return leadingVertices[0];
			
			// edge-edge collision
			if(axisFromS1) {
				goal = s2.center.copy();
				goal.add(rb2.center);
				var newVertices:Vector.<Vector2D> = findClosestVerticesAlongAxis(s1.nextVertices, 
					goal, collisionAxis);
				leadingVertices = leadingVertices.concat(newVertices);
			} else {
				goal = s1.center.copy();
				goal.add(rb1.center);
				newVertices = findClosestVerticesAlongAxis(s2.nextVertices, 
					goal, collisionAxis);
				leadingVertices = leadingVertices.concat(newVertices);
			}
			Vector2D.sortByDotProduct(leadingVertices, collisionAxis.getPerpendicular());
			return Vector2D.getAverage(leadingVertices[1], leadingVertices[2]);
		}
		
		private function findClosestVerticesAlongAxis(vertices:Vector.<Vector2D>, 
													  goal:Vector2D, axis:Vector2D):Vector.<Vector2D> {
			var result:Vector.<Vector2D> = new Vector.<Vector2D>();
			var len:uint = vertices.length;
			var goalDotProduct:Number = goal.dot(axis);
			var minDistance:Number = Math.abs(vertices[0].dot(axis) - goalDotProduct);
			result.push(vertices[0].copy());
			for(var i:uint = 1; i < len; i++) {
				var distance:Number = Math.abs(vertices[i].dot(axis) - goalDotProduct);
				if(CSQMath.equalWithin(minDistance, distance, 0.0001)) {
					result.push(vertices[i].copy());
				}
				else if(distance < minDistance) {
					result = new Vector.<Vector2D>();
					result.push(vertices[i].copy());
					minDistance = distance;
				}
			}
			return result;
		}
		
		private function getIndex(k:Number, arr:Array):uint {
			var len:uint = arr.length;
			for(var i:uint = 0; i < len; i++)
				if(CSQMath.equalWithin(arr[i], k, .001)) return i;
			// should never reach this point
			return arr.length;
		}
		
		private function findRadii():void {
			radius1 = impactVector.copy();
			radius1.subtract(rb1.center);
			radius1.subtract(s1.center);
			radius1.subtract(rb1.velocity);
			
			radius2 = impactVector.copy();
			radius2.subtract(rb2.center);
			radius2.subtract(s2.center);
			radius2.subtract(rb2.velocity);
		}
		
		private function findIPV():void {
			var radius1perp:Vector2D = radius1.getPerpendicular();
			var radius2perp:Vector2D = radius2.getPerpendicular();
			ipv = rb2.velocity.copy();
			var tempVec:Vector2D = radius2perp;
			tempVec.scale(rb2.angularVelocity);
			ipv.add(tempVec);
			ipv.subtract(rb1.velocity);
			tempVec = radius1perp;
			tempVec.scale(rb1.angularVelocity);
			ipv.add(tempVec);
		}
		
		// for debugging
		public function printResults():void {
			if(exists()) {
				trace("possible axes=",possibleAxes);
				trace("collision vector=",collisionVector,"from rb",axisFromS1 ? "1" : "2");
				trace("time=",penetrationTime);
				trace("impact vector=",impactVector);
				trace("radii=",radius1,radius2);
				trace("ipv=",ipv);
			} else
				trace("penetration does not occur");
		}
	}
}