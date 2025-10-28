import { Skill } from "./skills"

export const DesintegrateMage: Skill = {
  id: "desintegrate_mage",
  name: "Desintegrar",
  level: 10,
  baseDamage: 40,
  range: 30,
  area: 0,
  animation: "DesintegrateCast",
  effect: "Desintegrate",
  characterClass: "Mage",
  description: "Desintegra o inimigo com um raio de pura energia arcana",
  castTime: 2.5,
  needTarget: true,
  cooldown: 10,
  manaCost: 50
}
