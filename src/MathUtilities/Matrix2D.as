package MathUtilities
{
	public class Matrix2D
	{
		/* Class representing 2x2 matrices, designed exclusively to be used with the Vector2D class.
		Matrices have the form: | a  b |
								| c  d |
		*/
		
		public var a:Number;
		public var b:Number;
		public var c:Number;
		public var d:Number;
		
		public function Matrix2D(a:Number, b:Number, c:Number, d:Number)
		{
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
		}
		
		public function subtract(other:Matrix2D):void {
			this.a -= other.a;
			this.b -= other.b;
			this.c -= other.c;
			this.d -= other.d;
		}
		
		public static function getRotationMatrix(angle:Number, inRadians:Boolean=true):Matrix2D {
			if(!inRadians)
				angle *= Math.PI/180;
			
			return new Matrix2D(Math.cos(angle), -Math.sin(angle), Math.sin(angle), Math.cos(angle));
		}
		
		public static function getIdentityMatrix():Matrix2D {
			return new Matrix2D(1,0,1,0);
		}
		
		public static function solveAxb(A:Matrix2D, b:Vector2D):Vector2D {
			var k:Number = A.c/A.a;
			var x2:Number = (b.y - k*b.x)/(A.d - k*A.b)
			return new Vector2D(b.x - A.b*x2, x2);
		}
	}
}