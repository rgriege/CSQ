package DataStructures
{
	import DataStructures.LinkedListNode;
	
	public class LinkedList
	{
		private var first:LinkedListNode;
		private var last:LinkedListNode;
		
		public function LinkedList()
		{
			first = null;
			last = null;
		}
		
		public function getFirst():LinkedListNode {
			return first;
		}
		
		public function add(data:*):void {
			if(!first) {
				first = new LinkedListNode(data, null);
				last = first;
			} else {
				var newNode:LinkedListNode = new LinkedListNode(data, null);
				last.setNext(newNode);
				last = newNode;
			}
		}
		
		public function removeFirst():* {
			var temp:* = first.getData();
			first = first.getNext();
			return temp;
		}
		
		public function isEmpty():Boolean {
			if(!first)
				return true;
			else
				return false;
		}
	}
}