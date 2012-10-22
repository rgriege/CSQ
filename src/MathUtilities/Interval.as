package MathUtilities
{
	public class Interval
	{
		// stores the left limit
		public var leftLimit:Number;
		// stores the right limit
		public var rightLimit:Number;
		// stores whether or not the left limit is inclusive
		public var leftInclusive:Boolean;
		// stores whether or not the right limit is inclusive
		public var rightInclusive:Boolean;
		
		private static const EMPTY_INTERVAL:Interval = new Interval(0,0,false,false);
		
		public function Interval(left:Number, right:Number, leftInc:Boolean=true, rightInc:Boolean=true)
		{
			if(right < left)
				throw new Error("The right limit must be greater than or equal to the left limit");
			
			leftLimit = left;
			rightLimit = right;
			leftInclusive = leftInc;
			rightInclusive = rightInc;
		}
		
		// returns the length of the interval
		public function length():Number {
			return rightLimit - leftLimit;
		}
		
		// shifts the interval right for positive inputs, left for negative ones
		public function shift(num:Number):void {
			rightLimit += num;
			leftLimit += num;
		}
		
		// returns a copy of this interval
		public function copy():Interval {
			return new Interval(leftLimit, rightLimit, leftInclusive, rightInclusive);
		}
		
		// Returns the union of the this and the input intervals.
		// Neither this nor the input interval is changed
		public function union(other:Interval):Vector.<Interval> {
			var result:Vector.<Interval> = new Vector.<Interval>();
			var containsLeft:Boolean = this.contains(other.leftLimit);
			var containsRight:Boolean = this.contains(other.rightLimit);
			if(containsLeft && containsRight)
				result.push(new Interval(this.leftLimit, this.rightLimit));
			else if(containsLeft)
				result.push(new Interval(this.leftLimit, other.rightLimit));
			else if(containsRight)
				result.push(new Interval(other.leftLimit, this.rightLimit));
			else {
				result.push(this.copy(),other.copy());
			}
			return result;
		}
		
		// Returns the set difference of this interval and the input interval
		// Neither interval is changed as a result of this method
		public function setDifference(other:Interval):Vector.<Interval> {
			var result:Vector.<Interval> = new Vector.<Interval>();
			var containsLeft:Boolean = this.contains(other.leftLimit);
			var containsRight:Boolean = this.contains(other.rightLimit);
			if(containsLeft && containsRight) {
				result.push(new Interval(this.leftLimit, other.leftLimit));
				result.push(new Interval(other.rightLimit, this.rightLimit));
			} else if(containsLeft)
				result.push(new Interval(this.leftLimit, other.leftLimit));
			else if(containsRight)
				result.push(new Interval(other.rightLimit, this.rightLimit));
			else {
				if(other.rightLimit < this.leftLimit || other.leftLimit > this.rightLimit)
					result.push(this.copy());
				else
					result.push(Interval.EMPTY_INTERVAL);
			}
			return result;
		}
		
		// returns true if the interval contains no values
		public function isEmpty():Boolean {
			return leftLimit == rightLimit && !leftInclusive && !rightInclusive;
		}
		
		// returns true if the parameter is inside the interval
		public function contains(x:Number):Boolean {
			var leftSide:Boolean = false;
			if(leftInclusive)
				leftSide = (x >= leftLimit) ? true : false;
			else
				leftSide = (x > leftLimit) ? true : false;
			var rightSide:Boolean = false;
			if(rightInclusive)
				rightSide = (x <= rightLimit) ? true : false;
			else
				rightSide = (x < rightLimit) ? true : false;
			return leftSide && rightSide;
		}
		
		public function overlaps(other:Interval):Boolean {
			return this.contains(other.leftLimit) || other.contains(this.leftLimit);
		}
		
		// returns the amount of overlap between this and other (always positive)
		// returns 0 if the two do not overlap
		public function overlapDistance(other:Interval):Number {
			var maxDiff:Number = Math.max(this.length(), other.length());
			var diff1:Number = this.rightLimit - other.leftLimit;
			if(diff1 < 0 || diff1 > maxDiff) diff1 = 0;
			var diff2:Number = other.rightLimit - this.leftLimit;
			if(diff2 < 0 || diff2 > maxDiff) diff2 = 0;
			// return the smallest nonzero if one exists
			if(diff1 == 0 || diff2 == 0)
				return diff1 + diff2;
			else
				return Math.min(diff1, diff2);
		}
		
		public static function Inclusion(intervals:Vector.<Interval>):Interval {
			var result:Interval = new Interval(intervals[0].leftLimit, intervals[0].rightLimit);
			var len:uint = intervals.length;
			for(var i:uint = 0; i < len; i++) {
				if(intervals[i].leftLimit < result.leftLimit)
					result.leftLimit = intervals[i].leftLimit;
				if(intervals[i].rightLimit > result.rightLimit)
					result.rightLimit = intervals[i].rightLimit;
			}
			return result;
		}
		
		// Returns the union of the set of input intervals (must be sorted)
		// The input set of intervals IS altered
		public static function Union(intervals:Vector.<Interval>):void {
			if(intervals.length == 0)
				throw new Error("Cannot take the union of 0 intervals.");
			else if(intervals.length == 1)
				return;
			else {
				Interval.sortByLeftLimit(intervals);
				var index:uint = 0;
				while(index < intervals.length - 1) {
					var currentIntervals:Vector.<Interval> = intervals.slice(index, index + 2);
					currentIntervals = currentIntervals[0].union(currentIntervals[1]);
					if(currentIntervals.length != 1) {
						index++;
					} else {
						intervals.splice(index, 2, currentIntervals[0]);
					}
				}
			}
		}
		
		public static function sortByLeftLimit(intervals:Vector.<Interval>):void {
			var len:uint = intervals.length;
			for(var i:uint = 0; i < len; i++) {
				for(var j:uint = i+1; j < len; j++) {
					if(intervals[i].leftLimit > intervals[j].leftLimit) {
						var temp:Interval = intervals[i].copy();
						intervals[i] = intervals[j];
						intervals[j] = temp;
					}
				}
			}
		}
		
		// returns true if this interval has the same limits as the parameter other
		public function equals(other:Interval):Boolean {
			return leftLimit == other.leftLimit && rightLimit == other.rightLimit
				&& leftInclusive == other.leftInclusive && rightInclusive == other.rightInclusive;
		}
		
		// for debugging
		public function toString():String {
			return (leftInclusive ? "[" : "(")+leftLimit+","+rightLimit+(rightInclusive ? "]" : ")");
		}
	}
}