package Editor
{
	import Collisions.RigidBody;
	import Collisions.Shapes.AbstractShape;
	import Collisions.Shapes.Disk;
	import Collisions.Shapes.Polygon;
	import Collisions.Shapes.Ring;
	
	import MathUtilities.CSQMath;
	import MathUtilities.Vector2D;
	
	import assets.BottomBar;
	import assets.EditIcon;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Interface extends Sprite
	{
		public var toolbar:Toolbar;
		public var controlBar:ControlBar;
		public var editIcon:EditIcon;
		public var toolbox:Sprite;
		private var toolboxOffset:int = 10;
		public var hitBox:Sprite;
		private var drawType:String;
		private var drawnVertices:Vector.<Vector2D>;
		private var partialSprite:Sprite;
		public const colors:Array = [0xFF0000, 0x00FF00, 0x0000FF]
		public var colorIndex:uint = 0;
		
		public function Interface()
		{
			hitBox = new Sprite();
			hitBox.graphics.beginFill(0xff0000,0);
			toolbar = new Toolbar();
			
			controlBar = new ControlBar();
			addChild(controlBar);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			addChild(toolbar);
			
			partialSprite = new Sprite();
		}
		
		public function addedToStage(evt:Event):void {
			hitBox.graphics.drawRect(toolbar.width,0,stage.stageWidth,
									stage.stageHeight-controlBar.height);
			addChild(hitBox);
			toolbar.y = (stage.stageHeight - toolbar.height)/2;
			controlBar.x = (stage.stageWidth - controlBar.width)/2;
			controlBar.y = stage.stageHeight - controlBar.height;
		}
		
		public function beginDrawing(type:String):void {
			drawType = type;
			drawnVertices = new Vector.<Vector2D>();
			hitBox.addEventListener(MouseEvent.CLICK, drawVertex);
		}
		
		public function drawVertex(evt:MouseEvent):void {
			drawnVertices.push(new Vector2D(evt.stageX, evt.stageY));
			// start drawing partials after the first vertex is drawn
			if(!hitBox.hasEventListener(MouseEvent.MOUSE_MOVE)) {
				hitBox.addEventListener(MouseEvent.MOUSE_MOVE, drawPartial);
				addChildAt(partialSprite,0);
			}
			switch(drawType) {
				case "disk":
					if(drawnVertices.length == 2) {
						var radius:Number = CSQMath.distance(drawnVertices[0], drawnVertices[1]);
						var disk:Disk = new Disk(drawnVertices[0], radius, 1, colors[colorIndex]);
						dispatchEvent(new AddBodyEvent(AddBodyEvent.EVENT, disk));
						stopDrawing();
					}
					break;
				case "ring":
					if(drawnVertices.length == 3) {
						var iRadius:Number = CSQMath.distance(drawnVertices[0], drawnVertices[2]);
						var oRadius:Number = CSQMath.distance(drawnVertices[0], drawnVertices[1]);
						var ring:Ring = new Ring(drawnVertices[0], iRadius, oRadius, 1, colors[colorIndex]);
						dispatchEvent(new AddBodyEvent(AddBodyEvent.EVENT, ring));
						stopDrawing();
					}
					break;
				case "rectangle":
					if(drawnVertices.length == 2) {
						var center:Vector2D = Vector2D.getAverageFromVector(drawnVertices);
						for each(var v:Vector2D in drawnVertices) {
							v.subtract(center);
						}
						drawnVertices.splice(1,0,new Vector2D(drawnVertices[0].x, drawnVertices[1].y));
						drawnVertices.push(new Vector2D(drawnVertices[2].x, drawnVertices[0].y));
						var rect:Polygon = new Polygon(center, drawnVertices, 1, colors[colorIndex]);
						dispatchEvent(new AddBodyEvent(AddBodyEvent.EVENT, rect));
						stopDrawing();
					}
					break;
				case "polygon":
					var len:uint = drawnVertices.length;
					var finished:Boolean = false;
					for(var i:uint = 0; i < len-1; i++) {
						if(CSQMath.equalWithin(drawnVertices[i].x, drawnVertices[len-1].x, 5)
							&& CSQMath.equalWithin(drawnVertices[i].y, drawnVertices[len-1].y, 5))
							finished = true;
					}
					if(finished) {
						drawnVertices.splice(-1,1);
						center = Vector2D.getAverageFromVector(drawnVertices);
						for each(v in drawnVertices) {
							v.subtract(center);
						}
						var poly:Polygon = new Polygon(center, drawnVertices, 1, colors[colorIndex]);
						dispatchEvent(new AddBodyEvent(AddBodyEvent.EVENT, poly));
						stopDrawing();
					} else if(len > 2 && !isValidNewVertex())
						drawnVertices.splice(-1,1);
					break;
			}
		}
		
		public function drawPartial(evt:MouseEvent):void {
			partialSprite.graphics.clear();
			partialSprite.graphics.lineStyle(1,0x000000)
			partialSprite.graphics.beginFill(colors[colorIndex]);
			switch(drawType) {
				case "disk":
					partialSprite.graphics.drawCircle(drawnVertices[0].x,drawnVertices[0].y,
						CSQMath.distance(drawnVertices[0].x,drawnVertices[0].y,evt.stageX,evt.stageY));
					break;
				case "ring":
					if(drawnVertices.length == 1)
						partialSprite.graphics.drawCircle(drawnVertices[0].x,drawnVertices[0].y,
							CSQMath.distance(drawnVertices[0].x,drawnVertices[0].y,evt.stageX,evt.stageY));
					else {
						partialSprite.graphics.drawCircle(drawnVertices[0].x,drawnVertices[0].y,
							CSQMath.distance(drawnVertices[0],drawnVertices[1]));
						partialSprite.graphics.beginFill(0xffffff,0.4);
						partialSprite.graphics.drawCircle(drawnVertices[0].x,drawnVertices[0].y,
							CSQMath.distance(drawnVertices[0].x,drawnVertices[0].y,evt.stageX,evt.stageY));
					}
					break;
				case "rectangle":
					partialSprite.graphics.drawRect(drawnVertices[0].x, drawnVertices[0].y,
						evt.stageX - drawnVertices[0].x, evt.stageY - drawnVertices[0].y);
					break;
				case "polygon":
					var len:uint = drawnVertices.length;
					partialSprite.graphics.moveTo(drawnVertices[0].x, drawnVertices[0].y);
					for(var i:uint = 1; i < len; i++) {
						partialSprite.graphics.lineTo(drawnVertices[i].x, drawnVertices[i].y);
					}
					partialSprite.graphics.lineTo(evt.stageX, evt.stageY);
					partialSprite.graphics.lineTo(drawnVertices[0].x, drawnVertices[0].y);
					break;
			}
		}
		
		public function stopDrawing():void {
			colorIndex = (colorIndex+1)%colors.length;
			removeChild(partialSprite);
			hitBox.removeEventListener(MouseEvent.CLICK, drawVertex);
			hitBox.removeEventListener(MouseEvent.MOUSE_MOVE, drawPartial);
			partialSprite.graphics.clear();
		}
		
		// If the vertices are defined CCW, the new edge must point "left" of the old edge
		// and vice versa if the vertices are define CW.
		private function isValidNewVertex():Boolean {
			var len:uint = drawnVertices.length;
			var firstAxisPerp:Vector2D = drawnVertices[1].copy();
			firstAxisPerp.subtract(drawnVertices[0]);
			firstAxisPerp = firstAxisPerp.getPerpendicular();
			var secondAxis:Vector2D = drawnVertices[2].copy();
			secondAxis.subtract(drawnVertices[1]);
			var definedCCW:Boolean = secondAxis.dot(firstAxisPerp) >= 0;
			
			var prevAxisPerp:Vector2D = drawnVertices[len-2].copy();
			prevAxisPerp.subtract(drawnVertices[len-3]);
			prevAxisPerp = prevAxisPerp.getPerpendicular(definedCCW);
			var curAxis:Vector2D = drawnVertices[len-1].copy();
			curAxis.subtract(drawnVertices[len-2]);
			var firstAngleValid:Boolean = curAxis.dot(prevAxisPerp) >= 0;
			
			prevAxisPerp = curAxis.getPerpendicular(definedCCW);
			curAxis = drawnVertices[0].copy();
			curAxis.subtract(drawnVertices[len-1]);
			var secondAngleValid:Boolean = curAxis.dot(prevAxisPerp) >= 0;
			
			prevAxisPerp = curAxis.getPerpendicular(definedCCW);
			curAxis = drawnVertices[1].copy();
			curAxis.subtract(drawnVertices[0]);
			var thirdAngleValid:Boolean = curAxis.dot(prevAxisPerp) >= 0;
			return firstAngleValid && secondAngleValid && thirdAngleValid;
		}
		
		public function addEditIcon(rb:RigidBody):void {
			editIcon = new EditIcon();
			
			if(rb.center.x < stage.stageWidth/2) {
				toolbox.x = rb.center.x + toolboxOffset;
				if(rb.center.y < stage.stageHeight/2) {
					toolbox.y = rb.center.y + toolboxOffset;
				} else {
					toolbox.y = rb.center.y - toolboxOffset - toolbox.height;
					toolbox.rotation = -90;
				}
			} else {
				toolbox.x = rb.center.x - 15 - toolbox.width;
				if(rb.center.y < stage.stageHeight/2) {
					toolbox.y = rb.center.y + toolboxOffset;
					toolbox.rotation = 90;
				} else {
					toolbox.y = rb.center.y - toolboxOffset - toolbox.height;
					toolbox.rotation = 180;
				}
			}
			addChild(toolbox);
			toolbox.addEventListener(MouseEvent.MOUSE_OVER, expandToolbox);
		}
		
		private function expandToolbox(evt:MouseEvent):void {
			toolbox.removeEventListener(MouseEvent.MOUSE_OVER, expandToolbox);
			toolbox.addEventListener(MouseEvent.MOUSE_OUT, collapseToolbox);
		}
		
		private function collapseToolbox(evt:MouseEvent):void {
			toolbox.addEventListener(MouseEvent.MOUSE_OVER, expandToolbox);
		}
		
		public function removeToolbox():void {
			if(toolbox.hasEventListener(MouseEvent.MOUSE_OVER))
				toolbox.removeEventListener(MouseEvent.MOUSE_OVER, expandToolbox);
			else if(toolbox.hasEventListener(MouseEvent.MOUSE_OUT))
				toolbox.removeEventListener(MouseEvent.MOUSE_OUT, collapseToolbox);
			removeChild(toolbox);
		}
	}
}