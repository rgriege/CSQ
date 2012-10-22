package DataStructures
{
	public class Integer implements Comparable
	{
		public var val:int;
		
		public function Integer(num:int)
		{
			val = num;
		}
		
		public function compareTo(other:Comparable):int {
			if(other is Integer) {
				if(this.val < (other as Integer).val)
					return -1;
				else if(this.val > (other as Integer).val)
					return 1;
				else
					return 0;
			} else
				return undefined;
		}
	}
}