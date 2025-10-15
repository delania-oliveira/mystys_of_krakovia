import { Skill } from "./skills"

export const DesintegrateMage: Skill = {
  id: "desintegrate_mage",
  name: "Desintegrar",
  level: 1,
  baseDamage: 30,
  range: 30,
  area: 0,
  animation: "DesintegrateCast",
  effect: "Desintegrate",
  characterClass: "Mage",
  description: "Desintegra o alvo com um raio poderoso.",
  castTime: 2.5,
  needTarget: true,
  cooldown: 10
}
