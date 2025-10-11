import { Skill } from "./skills"

export const DefaultSkillArcher: Skill = {
  id: "default_skill_hunter",
  name: "Flechada",
  level: 1,
  baseDamage: 2,
  area: 0,
  animation: "DefaultAttack",
  effect: "ArrowShot",
  characterClass: "Hunter",
  description: "Atira uma flecha no alvo.",
}

export const DefaultSkillMage: Skill = {
  id: "default_skill_mage",
  name: "Bola Arcana",
  level: 1,
  baseDamage: 4,
  area: 0,
  animation: "DefaultCast",
  effect: "ArcaneBall",
  characterClass: "Mage",
  description: "Lança uma bola arcana explosiva no alvo.",
}