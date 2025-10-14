import { Skill } from "./skills"

export const DefaultSkillArcher: Skill = {
  id: "default_skill_archer",
  name: "Flechada",
  level: 1,
  baseDamage: 2,
  range: 30,
  area: 0,
  animation: "DefaultAttack",
  effect: "ArrowShot",
  characterClass: "Archer",
  description: "Atira uma flecha no alvo.",
  needTarget: true
}

export const DefaultSkillMage: Skill = {
  id: "default_skill_mage",
  name: "Bola Arcana",
  level: 1,
  baseDamage: 4,
  range: 25,
  area: 0,
  animation: "DefaultCast",
  effect: "ArcaneBall",
  characterClass: "Mage",
  description: "Lança uma bola arcana explosiva no alvo.",
  castTime: 1.0,
  needTarget: true
}