import { Room, Client } from "@colyseus/core";
import { MyRoomState } from "./schema/MyRoomState";
import { Player } from "./schema/Player";
import { db } from "../db/connection";
import { accounts } from "../db/schema/accounts";
import { eq } from "drizzle-orm";

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

    this.onMessage("login", async (client: Client, data: { name: string; password?: string }) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.name = data.name;
        try {
          const existing = await db.select().from(accounts).where(eq(accounts.account_name, data.name))
          if (existing.length > 0) {
            if (existing[0].password === data.password) {
              client.send("loginResult", { success: true, message: "Login successful!" });
            } else {
              client.send("loginFail", { success: false, message: "Wrong account name or password!"})
            }
            return
          }
          const result = await db.insert(accounts).values({
            account_name: data.name,
            password: data.password
          }).returning()
          const newAccount = result[0]
          if (!newAccount) {
            throw new Error("Failed to create account")
          }
          client.send("accountCreated", { success: true, message: newAccount.account_name })
        } catch (error) {
          console.log(error)
          client.send("loginError", { success: false, message: "Database error" })          
        }
      }
    });

    this.onMessage("look", (client, data) => {
      const player = this.state.players.get(client.sessionId);
      if (player) {
        player.dirX = data.dirX;
        player.dirY = 0;
        player.dirZ = data.dirZ;
      }
    });

    this.onMessage("jump", (client) => {
      const player = this.state.players.get(client.sessionId);
      if (player && player.onGround) {
        player.vy = JUMP_STRENGTH;
        player.onGround = false;
      }
    });

    this.setSimulationInterval((dtMs) => this.update(dtMs), 25);
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
