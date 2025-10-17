import { Skill } from "./skills";

export const WarcryWarrior: Skill = {
  id: "warcry_warrior",
  name: "Grito de Guerra",
  level: 10,
  baseDamage: 0,
  range: 0,
  area: 30,
  animation: "Buff",
  effect: "WarcryWarrior",
  characterClass: "Warrior",
  description: "Warcry",
  needTarget: false,
  cooldown: 30,
  buffDef: 5,
  buffAtk: 5,
  buffDuration: 30,
  manaCost: 25
}