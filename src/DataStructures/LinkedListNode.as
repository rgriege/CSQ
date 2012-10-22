package DataStructures
{
	public class LinkedListNode
	{
		private var next:LinkedListNode;
		private var data:*;
		
		public function LinkedListNode(data:*, next:LinkedListNode)
		{
			this.data = data;
			this.next = next;
		}
		
		public function getData():* {
			return data;
		}
		
		public function getNext():LinkedListNode {
			return next;
		}
		
		public function setData(data:*):void {
			this.data = data;
		}
		
		public function setNext(node:LinkedListNode):void {
			this.next = node;
		}
	}
}