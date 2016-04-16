package {

    import flash.display.Sprite;

    public class Spaceship extends Sprite {

        public var xHome:Number = 0;
        public var yHome:Number = 0;
        public var rotationHome:Number = 0;

        public function Spaceship():void
        {
            // draw a simple triangle
            this.graphics.beginFill(0x66ff00, 1);
            this.graphics.moveTo(0, 0);
            this.graphics.lineTo(-20, 10);
            this.graphics.lineTo(-20, -10);
            this.graphics.lineTo(0, 0);
            this.graphics.endFill();
            this.cacheAsBitmap = true;
        }
    }
}
