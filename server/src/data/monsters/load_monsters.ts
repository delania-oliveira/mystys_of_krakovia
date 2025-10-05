import fs from "fs";
import { XMLParser } from "fast-xml-parser";
import type { MonsterType } from "./monster_type";
import type { MonstersXML } from "./monster_type";
import path from "path"

export function loadMonsters() {
  const filePath = path.join(__dirname, 'monsters.xml');
  const xmlData = fs.readFileSync(filePath, "utf8");
  const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: "" });
  const result = parser.parse(xmlData) as MonstersXML;

  return result.monsters.monster.map((m: MonsterType) => ({
    id: m.id,
    name: m.name,
    type: m.type,
    hp: Number(m.hp),
    attack: Number(m.attack),
    defense: Number(m.defense),
    speed: Number(m.speed),
    x: Number(m.x),
    y: Number(m.y),
    z: Number(m.z),
  }));
}