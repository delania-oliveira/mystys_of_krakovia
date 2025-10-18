import { Skill } from "./skills"

export const DrainLifeBloodMage: Skill = {
  id: "drain_life_blood_mage",
  name: "Drenar Vida",
  level: 1,
  baseDamage: 10,
  range: 30,
  area: 0,
  animation: "DrainLifeCast",
  effect: "DrainLife",
  characterClass: "Blood Mage",
  description: "Um ritual profano que transforma dor em poder. O sangue dos inimigos se torna o combustível da sobrevivência do mago de sangue.",
  castTime: 1.5,
  needTarget: true,
  cooldown: 0,
  manaCost: 20
}
