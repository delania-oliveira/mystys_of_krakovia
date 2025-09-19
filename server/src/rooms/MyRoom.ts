import { Room, Client } from "@colyseus/core";
import { MyRoomState } from "./schema/MyRoomState";
import { Player } from "./schema/Player";

const GRAVITY = 20;
const JUMP_STRENGTH = 10;
const GROUND_LEVEL = 0;

export class MyRoom extends Room<MyRoomState> {
  maxClients = 4;
  SPEED = 0.24
   
  onCreate(options: any) {
    this.state = new MyRoomState();
    
    // Example: handle custom messages
    this.onMessage("move", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.x += data.x;
        player.y += data.y;
        player.z += data.z;
      }
    });

    this.onMessage("look", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.dirX = data.dirX;
        player.dirY = 0;
        player.dirZ = data.dirZ;
        console.log(player.dirX)
        console.log(player.dirZ)
      }
    });

    this.onMessage("jump", (client) => {
      const player = this.state.players.get(client.sessionId);
      if (player && player.onGround) {
        player.vy = JUMP_STRENGTH;
        player.onGround = false;
      }
    });

    this.setSimulationInterval((dtMs) => this.update(dtMs), 50);
  }
  update(dtMs: number) {
    const dt = dtMs / 1000; // convert to seconds

    this.state.players.forEach((player) => {
      // apply gravity
      player.vy -= GRAVITY * dt;

      // integrate vertical position
      player.y += player.vy * dt;

      // ground collision
      if (player.y <= GROUND_LEVEL) {
        player.y = GROUND_LEVEL;
        player.vy = 0;
        player.onGround = true;
      }
    });
  }
  onJoin(client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new Player();
    player.x = 0;
    player.y = 0;
    player.z = 0;
    player.dirZ = -1;
    player.dirY = 0;
    player.dirX = 0
    this.state.players.set(client.sessionId, player);
    // THIS will trigger players:add on all clients
  }

  onLeave(client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId);
    // THIS will trigger players:remove on all clients
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }
}
