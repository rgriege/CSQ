package MathUtilities
{
	public class Vector2D
	{
		/* Any method that returns a Vector2D object does not modify this instance */
		
		// internal storage 'container'
		public var x:Number;
		public var y:Number;
		// static constants
		public static const X_AXIS:Vector2D = new Vector2D(1,0);
		public static const Y_AXIS:Vector2D = new Vector2D(0,1);
		
		public function Vector2D(x:Number=0, y:Number=0)
		{
			this.x = x;
			this.y = y;
		}
		
		// returns the magnitude of the vector (pythagorean theorem)
		public function magnitude():Number {
			if(isZero())
				return 0;
			else
				return Math.sqrt(x*x + y*y);
		}
		
		// returns the square of the magnitude (avoids unnecessary sqrt calculations)
		public function magSquared():Number {
			return x*x + y*y;
		}
		
		// returns an angle from -180 to 180
		// starts w/ 0 on the positive x axis, rotating clockwise for positive angles
		public function angle():Number {
			return Math.atan2(y, x)*180/Math.PI;
		}
		
		// returns a new unit vector from this vector
		public function unitVector():Vector2D {
			if(isZero())
				return this;
			var mag:Number = magnitude();
			return new Vector2D(x/mag, y/mag);
		}
		
		// returns true if this vector is a unit vector (has magnitude 1)
		public function isUnitVector():Boolean {
			return magnitude() == 1;
		}
		
		// vector addition
		public function add(other:Vector2D):void {
			x += other.x;
			y += other.y;
		}
		
		// vector subtraction
		public function subtract(other:Vector2D):void {
			x -= other.x;
			y -= other.y;
		}
		
		// scalar multiplication
		public function scale(num:Number):void {
			x *= num;
			y *= num;
		}
		
		// dot product
		public function dot(other:Vector2D):Number {
			return this.x*other.x + this.y*other.y;
		}
		
		// Returns the magnitude of the cross product of this vector with other
		// since the actual vector would be in a third dimension
		public function magOfCross(other:Vector2D):Number {
			return this.magnitude()*other.project(this.getPerpendicular()).magnitude();
		}
		
		public function cross(other:Vector2D):Number {
			return this.x*other.y - this.y*other.x;
		}
		
		public static function signOfCross(v1:Vector2D, v2:Vector2D):Number {
			var proj:Vector2D = v1.project(v2);
			var perp:Vector2D = v1.copy();
			perp.subtract(proj);
			if(perp.dot(v2.getPerpendicular(false)) > 0)
				return 1;
			else
				return -1;
		}
		
		// return a new vector of this vector projected onto a unit vector of the parameter
		public function project(vector:Vector2D):Vector2D {
			
			var result:Vector2D = vector.copy();
			result = result.unitVector();
			result.scale(this.dot(vector));
			return result;
		}
		
		// multiplies this vector by the input matrix
		public function multiply(matrix:Matrix2D):void {
			var newX:Number = matrix.a*this.x + matrix.b*this.y;
			this.y = matrix.c*this.x + matrix.d*this.y;
			this.x = newX;
		}
		
		// rotates this vector CCW by the input angle
		public function rotate(angle:Number, inRadians:Boolean=true):void {
			this.multiply(Matrix2D.getRotationMatrix(-angle, inRadians));
		}
		
		// returns a new vector perpendicular to this vector (left normal)
		public function getPerpendicular(left:Boolean=true):Vector2D {
			if(left)
				return new Vector2D(y, -x);
			else
				return new Vector2D(-y, x);
		}
		
		// inverts this vector
		public function invert():Vector2D {
			return new Vector2D(-x,-y);
		}
		
		// returns true if this vector and the other vector share a quadrant, meaning
		// the angle between them is between 0 and 90, inclusive
		public function sharesQuadrant(other:Vector2D):Boolean {
			return this.dot(other) >= 0;
		}
		
		// returns true if this vector is parallel to other
		// for this implementation, (0,0) is parallel to everything
		public function isParallelTo(other:Vector2D):Boolean {
			var result:Boolean;
			if(other.x != 0) {
				var k:Number = this.x/other.x;
				result = CSQMath.equalWithin(this.y, other.y * k, .0001);
			} else if(this.x == 0) {
				result = (this.y == 0 && other.y == 0) || (this.y != 0 && other.y != 0);
			} else
				result = other.y == 0;
			return result;
		}
		
		// returns true if the magnitude is zero
		public function isZero():Boolean {
			return x == 0 && y == 0;
		}
		
		// returns true if the two vectors are equal
		public function equals(other:Vector2D):Boolean {
			return x == other.x && y == other.y;
		}
		
		// returns a deep copy of this vector
		public function copy():Vector2D {
			return new Vector2D(x, y);
		}
		
		// rounds each compenent of the vector to the nearest whole number
		public function round(numDigits:uint):void {
			var factor:uint = Math.pow(10,numDigits);
			this.x = Math.round(x*factor)/factor;
			this.y = Math.round(y*factor)/factor;
		}
		
		public static function getAverage(v1:Vector2D, v2:Vector2D):Vector2D {
			return new Vector2D((v1.x + v2.x)/2, (v1.y + v2.y)/2);
		}
		
		public static function getAverageFromVector(vecs:Vector.<Vector2D>):Vector2D {
			var result:Vector2D = new Vector2D(0,0);
			var len:uint = vecs.length;
			for(var i:uint = 0; i < len; i++) {
				result.add(vecs[i]);
			}
			result.scale(1/len);
			return result;
		}
		
		public static function sortByDotProduct(vectors:Vector.<Vector2D>, axis:Vector2D):void {
			var len:uint = vectors.length;
			var dps:Vector.<Number> = new Vector.<Number>();
			for(var i:uint = 0; i < len; i++)
				dps.push(vectors[i].dot(axis));
			for(i = 0; i < len; i++) {
				for(var j:uint = i+1; j < len; j++)
					if(dps[i] > dps[j]) {
						var tempNum:Number = dps[i];
						dps[i] = dps[j];
						dps[j] = tempNum;
						var tempVec:Vector2D = vectors[i].copy();
						vectors[i] = vectors[j].copy();
						vectors[j] = tempVec;
					}
			}
		}
		
		// for debugging
		public function toString():String {
			return x+","+y;
		}
	}
}