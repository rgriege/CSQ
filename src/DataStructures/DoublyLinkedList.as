package DataStructures
{
	import DataStructures.DoublyLinkedListNode;
	
	public class DoublyLinkedList
	{
		private var first:DoublyLinkedListNode;
		private var last:DoublyLinkedListNode;
		
		public function DoublyLinkedList()
		{
			first = null;
			last = null;
		}
		
		public function addLast(data:*):void {
			var newNode:DoublyLinkedListNode = new DoublyLinkedListNode(last, data, null);
			if(last)
				last.setNext(newNode);
			if(!first)
				first = newNode;
			last = newNode;
			//trace("0",last);
		}
		
		public function getLast():* {
			if(last)
				return last.getData();
			else
				return null;
		}
		
		public function removeLast():* {
			//trace("2",last);
			if(last.getPrev())
				last.getPrev().setNext(null);
			if(first == last)
				first = null;
			var temp:* = last.getData();
			last = last.getPrev();
			return temp;
		}
		
		public function isEmpty():Boolean {
			return first == null;
		}
		
		public function toString():String {
			var temp:String = new String("(");
			var iteratingNode:DoublyLinkedListNode = first;
			while(iteratingNode) {
				temp += iteratingNode.toString() + ", ";
				iteratingNode = iteratingNode.getNext();
			}
			temp += ")";
			return temp;
		}
	}
}