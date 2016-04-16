package
{
import flash.display.MovieClip;
import flash.display.StageScaleMode;
import flash.events.Event;

import flash.net.NetConnection;
import flash.events.NetStatusEvent;

import flash.net.SharedObject;
import flash.events.SyncEvent;

import PlayerSpaceship;
import Spaceship;

    // @quintenclause 4 #bcgenk
    // Multiplayer Demo

    public class Game extends MovieClip
    {
        private var player:PlayerSpaceship; // the ship that can be controlled by the player
        private var opponentArr:Array = new Array(); // the ships controlled by players on the net

        private var rtmpPath:String = "rtmp://domain.net/ConnectToSharedObject";
        //private var rtmpPath:String = "rtmpt://domain.net/ConnectToSharedObject"; // via http (passes more firewalls)
        private var uniqID:String;
        private var localSO:SharedObject;
        private var remoteSO:SharedObject;
        private var nc:NetConnection;
        private var good:Boolean;

        public function Game()
        {
            trace("Get ready to camp!");
            this.addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void
        {
            stage.scaleMode = StageScaleMode.SHOW_ALL;
            // add the player to the stage
            player = new PlayerSpaceship();
            player.x = stage.stageWidth / 2;
            player.y = stage.stageHeight/ 2;
            this.addChild(player);

            makeConnection();
        }

        public function makeConnection():void
        {
            // retrieve locally stored id or make a new id if none
            var uniqNumber:Number = Math.ceil(Math.random() * 1000000000);
            localSO = SharedObject.getLocal("qube-id", "/");
            uniqID = (localSO.data.uniqID) ? (localSO.data.uniqID) : uniqNumber.toString();
            localSO.data.uniqID = uniqID;
            trace("Player id = " + uniqID);
            // connect to server
            nc=new NetConnection();
            nc.connect(rtmpPath);
            nc.addEventListener (NetStatusEvent.NET_STATUS, doSO);
        }

        // when connection to server is okay
        private function doSO (e:NetStatusEvent):void
        {
            good = e.info.code == "NetConnection.Connect.Success";
            if (good) {
                trace("Connected to server.");
                // connect the remote shared object
                remoteSO=SharedObject.getRemote("bcgenk",nc.uri,false);
                remoteSO.connect(nc);
                remoteSO.addEventListener(SyncEvent.SYNC, doUpdate);
                this.addEventListener(Event.ENTER_FRAME, onF);
            } else {
                trace("Not Connected to server.");
            }
        }

        // each Frame
        public function onF(e:Event):void
        {
            // only...
            if (player.moving && remoteSO) {
                // pass the relevant properties to the server
                var entObj:Object = new Object();
                entObj.x = player.x;
                entObj.y = player.y;
                entObj.rotation = player.rotation;
                remoteSO.setProperty(uniqID, entObj);
            }
            // smooth animation of opponents
            for (var i in opponentArr) {
                if (opponentArr[i].xHome < 0 || opponentArr[i].xHome > stage.stageWidth) {
                    opponentArr[i].x = opponentArr[i].xHome;
                } else {
                    opponentArr[i].x += (opponentArr[i].xHome - opponentArr[i].x)* .2;
                }
                if (opponentArr[i].yHome < 0 || opponentArr[i].yHome > stage.stageHeight) {
                    opponentArr[i].y = opponentArr[i].yHome;
                } else {
                    opponentArr[i].y += (opponentArr[i].yHome - opponentArr[i].y)* .2;
                }
                opponentArr[i].rotation += (opponentArr[i].rotationHome - opponentArr[i].rotation);
            }
        }

        // handle incoming sync requests

        private function doUpdate (se:SyncEvent):void
        {
            for (var cl:uint; cl < se.changeList.length; cl++) {
                if (se.changeList[cl].code == "change") {
                    if (opponentArr[se.changeList[cl].name] == undefined && se.changeList[cl].name != uniqID) {
                        // when there is no opponent with id: create him
                        opponentArr[se.changeList[cl].name] = new Spaceship();
                        opponentArr[se.changeList[cl].name].xHome = remoteSO.data[se.changeList[cl].name].x;
                        opponentArr[se.changeList[cl].name].yHome = remoteSO.data[se.changeList[cl].name].y;
                        opponentArr[se.changeList[cl].name].rotationHome = remoteSO.data[se.changeList[cl].name].rotation;
                        this.addChild(opponentArr[se.changeList[cl].name]);
                        trace("New Opponent = " + opponentArr[se.changeList[cl].name]);
                    } else if (se.changeList[cl].name != uniqID) {
                        // when there is already an opponent with id: just move him
                        opponentArr[se.changeList[cl].name].xHome = remoteSO.data[se.changeList[cl].name].x;
                        opponentArr[se.changeList[cl].name].yHome = remoteSO.data[se.changeList[cl].name].y;
                        opponentArr[se.changeList[cl].name].rotationHome = remoteSO.data[se.changeList[cl].name].rotation;
                    }
                }
            }
        }
    }
}
