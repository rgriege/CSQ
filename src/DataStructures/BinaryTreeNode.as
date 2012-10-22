package DataStructures
{
	import DataStructures.Comparable;
	
	public class BinaryTreeNode implements Comparable
	{
		private var data:Comparable;
		private var left:BinaryTreeNode;
		private var right:BinaryTreeNode;
		
		public function BinaryTreeNode(data:Comparable)
		{
			this.data = data;
			left = null;
			right = null;
		}
		
		public function getLeft():BinaryTreeNode {
			return left;
		}
		
		public function getData():Comparable {
			return data;
		}
		
		public function getRight():BinaryTreeNode {
			return right;
		}
		
		public function setLeft(node:BinaryTreeNode):void {
			left = node;
		}
		
		public function setData(data:Comparable):void {
			this.data = data;
		}
		
		public function setRight(node:BinaryTreeNode):void {
			right = node;
		}
		
		public function compareTo(other:Comparable):int
		{
			if(other is BinaryTreeNode)
				return this.data.compareTo((other as BinaryTreeNode).data);
			else
				return undefined;
		}
	}
}