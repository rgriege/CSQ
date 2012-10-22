package MathUtilities.Functions
{
	import MathUtilities.CSQMath;
	
	public class AbstractFunction
	{
		public var coefficients:Array;
		
		public function AbstractFunction(...coeffs)
		{
			coefficients = coeffs;
		}
		
		// should be overridden
		public function f(x:Number):Number {
			return 0;
		}
		
		public function findRoot(left:Number, right:Number, tolerance:Number):Number {
			tolerance = Math.abs(tolerance);
			var root:Number;
			var froot:Number = tolerance+1; 
			while(Math.abs(froot) > tolerance) {
				var fleft:Number = f(left);
				var fright:Number = f(right);
				root = (fright*left - fleft*right)/(fright - fleft);
				froot = f(root);
				if(CSQMath.sameSign(fleft, froot))
					left = root;
				else
					right = root;
			}
			return root;
		}
	}
}