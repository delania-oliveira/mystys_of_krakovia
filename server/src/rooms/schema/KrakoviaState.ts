import { Schema, type, MapSchema } from "@colyseus/schema";
import { Player } from "./Player";
import { Monster } from "./Monster";

export class KrakoviaState extends Schema {
  @type({ map: Player }) players = new MapSchema<Player>();
  @type({ map: Monster }) monsters = new MapSchema<Monster>();
}
