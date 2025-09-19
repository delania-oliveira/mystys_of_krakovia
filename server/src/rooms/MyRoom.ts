import { Room, Client } from "@colyseus/core";
import { MyRoomState } from "./schema/MyRoomState";
import { Player } from "./schema/Player";

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
      console.log(player)
    });
  }

  onJoin(client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new Player();
    player.x = 0;
    player.y = 0;
    player.z = 0;
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
