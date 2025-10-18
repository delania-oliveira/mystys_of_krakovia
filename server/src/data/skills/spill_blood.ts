import { Skill } from "./skills"

export const SpillBloodBloodMage: Skill = {
  id: "spill_blood_blood_mage",
  name: "Derramar Sangue",
  level: 10,
  baseDamage: 0,
  range: 0,
  area: 60,
  animation: "Standing2HCastSpell01",
  effect: "SpillBlood",
  characterClass: "Blood Mage",
  description: "Um ritual de sangue que une o grupo sob um mesmo pacto. Cada gota derramada fortalece todos com poder e resistência.",
  castTime: 3.0,
  needTarget: false,
  cooldown: 60,
  manaCost: 20,
  buffDef: 0,
  buffAtk: 4,
  buffDuration: 60,
}
