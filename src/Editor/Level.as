package Editor
{
	import Collisions.Interactions;
	import Collisions.RigidBody;
	
	import MathUtilities.Vector2D;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Level extends Sprite
	{
		private var fileReference:FileReference;
		public var interactions:Interactions;
		public var title:TextField;
		private var titleFormat:TextFormat;
		
		public function Level(name:String="Level")
		{
			this.name = name;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			title = new TextField();
			title.text = name;
			titleFormat = new TextFormat();
			titleFormat.size = 24;
			titleFormat.font = "arial";
			titleFormat.align = "center";
			title.y = 20;
			title.width = 400;
			title.selectable = false;
			title.setTextFormat(titleFormat);
			addChild(title);
			interactions = new Interactions();
			addChild(interactions);
		}
		
		public function addedToStage(evt:Event):void {
			title.x = stage.stageWidth/2 - title.width/2;
		}
		
		public function removedFromStage(evt:Event):void {
			
		}
		
		public function toggle():void {
			interactions.toggle();
		}
		
		public function importFile():void {
			fileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, fileSelected);
			fileReference.browse();
		}
		
		private function fileSelected(evt:Event):void {
			fileReference.removeEventListener(Event.SELECT, fileSelected);
			fileReference.addEventListener(Event.COMPLETE, fileLoaded);
			fileReference.load();
		}
		
		private function fileLoaded(evt:Event):void {
			fileReference.removeEventListener(Event.COMPLETE, fileLoaded);
			loadLevelFromFileReference();
		}
		
		public function loadLevelFromFileReference():void {
			var file:SaveFile = new SaveFile(fileReference.data.toString());
			removeChild(interactions);
			interactions = new Interactions();
			interactions.importData(file);
			addChild(interactions);
			name = getTitleFromFileReference(fileReference.name);
			title.text = name;
			title.setTextFormat(titleFormat);
		}
		
		public function exportToTextFile():void {
			var data:String = interactions.exportData();
			var fileRef:FileReference = new FileReference();
			fileRef.save(data, name);
		}
		
		private function getTitleFromFileReference(fileName:String):String {
			return fileName.substring(0, fileName.indexOf(".txt"));
		}
	}
}