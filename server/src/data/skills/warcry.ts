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
  description: "O rugido do guerreiro ecoa pelo campo de batalha, fortalecendo sua força e resistência.",
  needTarget: false,
  cooldown: 30,
  buffDef: 2,
  buffAtk: 2,
  buffDuration: 30,
  manaCost: 25
}