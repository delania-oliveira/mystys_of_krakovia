import { Skill } from "./skills"

export const SpillBloodBloodMage: Skill = {
  id: "spill_blood_blood_mage",
  name: "Derramar Sangue",
  level: 10,
  baseDamage: 0,
  range: 30,
  area: 0,
  animation: "SpillBloodCast",
  effect: "DrainLife",
  characterClass: "Blood Mage",
  description: "Um ritual de sangue que une o grupo sob um mesmo pacto. Cada gota derramada fortalece todos com poder e resistência.",
  castTime: 3.0,
  needTarget: true,
  cooldown: 0,
  manaCost: 20
}
