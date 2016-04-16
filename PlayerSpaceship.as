package
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    public class PlayerSpaceship extends Spaceship
    {
        // movement
        public var moving:Boolean = false;
        private var speed:int = 0;
        private var maxSpeed:int = 16;

        // for ui keyboard
        private var rightKeyPressed:Boolean = false;
        private var leftKeyPressed:Boolean = false;
        private var upKeyPressed:Boolean = false;
        private var downKeyPressed:Boolean = false;
        // for uiMouse
        private var lastMouseX:Number = 0;

        public function PlayerSpaceship()
        {
            this.addEventListener(Event.ADDED_TO_STAGE, init);
        }

        // setup ui
        public function init(e:Event = null):void
        {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMDown);
            stage.addEventListener(Event.ENTER_FRAME, onF);
            this.addEventListener(Event.REMOVED_FROM_STAGE, deInit);
        }

        // set rotation, calculate the speed and set position
        public function onF(e:Event):void
        {
            if (rightKeyPressed && !leftKeyPressed) {
                this.rotation += 6;
            } else if (!rightKeyPressed && leftKeyPressed) {
                this.rotation -= 6;
            }
            if (upKeyPressed && !downKeyPressed) {
                speed += (maxSpeed - speed)/10;
            } else if (downKeyPressed && !upKeyPressed) {
                speed += ((- maxSpeed) - speed)/10;
            }else{
                speed += (0 - speed)/10;
            }
            if (speed > 1 || speed < -1) {
                moving = true;
            } else {
                moving = false;
            }
            this.x += speed * Math.cos(this.rotation * Math.PI/180);
            this.y += speed * Math.sin(this.rotation * Math.PI/180);
            if (this.x > stage.stageWidth) {
                this.x = stage.stageWidth;
                speed *= -2;
            }
            if (this.y > stage.stageHeight) {
                this.y = stage.stageHeight;
                speed *= -2;
            }
            if (this.x < 0) {
                this.x = 0;
                speed *= -2;
            }
            if (this.y < 0) {
                this.y = 0;
                speed *= -2;
            }
        }

        // handle a real keyboard
        public function onKUp(e:KeyboardEvent):void
        {
            switch(e.keyCode){
                case Keyboard.RIGHT:
                    rightKeyPressed = false;
                 break;
                case Keyboard.LEFT:
                    leftKeyPressed = false;
                    break;
                case Keyboard.UP:
                    upKeyPressed = false;
                    break;
                case Keyboard.DOWN:
                    downKeyPressed = false;
                    break;
            }
        }

        public function onKDown(e:KeyboardEvent):void
        {
            switch(e.keyCode){
                case Keyboard.RIGHT:
                    rightKeyPressed = true;
                 break;
                case Keyboard.LEFT:
                    leftKeyPressed = true;
                    break;
                case Keyboard.UP:
                    upKeyPressed = true;
                    break;
                case Keyboard.DOWN:
                    downKeyPressed = true;
                    break;
            }
        }

        // simulate keyboard on screen with mouse/drag
        public function onMDown(e:MouseEvent):void
        {
            lastMouseX = stage.mouseX;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMUp);
            upKeyPressed = true;
        }

        public function onMUp(e:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMUp);
            upKeyPressed = false;
            lastMouseX = stage.mouseX;
            rightKeyPressed = false;
            leftKeyPressed = false;
        }

        public function onMMove(e:MouseEvent):void
        {
            if ((stage.mouseX - lastMouseX) > 90) {
                leftKeyPressed = false;
                rightKeyPressed = true;
            } else if ((stage.mouseX - lastMouseX) < -90) {
                rightKeyPressed = false;
                leftKeyPressed = true;
            } else {
                rightKeyPressed = false;
                leftKeyPressed = false;
            }
        }

        // allow garbage collection when removed from stage
        public function deInit(e:Event = null):void
        {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP, onKUp);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMDown);
            stage.removeEventListener(Event.ENTER_FRAME, onF);
        }
    }
}
