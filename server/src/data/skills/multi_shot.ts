import { Skill } from "./skills"

export const MultiShotArcher: Skill = {
  id: "multi_shot_archer",
  name: "Tiro Múltiplo",
  level: 3,
  baseDamage: 1,
  range: 30,
  area: 10,
  animation: "MultiShot",
  effect: "ArrowMultiShot",
  characterClass: "Archer",
  description: "Atira flechas em múltiplos alvos",
  needTarget: true
}
