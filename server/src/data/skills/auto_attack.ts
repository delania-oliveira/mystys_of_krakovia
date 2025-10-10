import { Skill } from "./skills"

export const AutoAttackHunter: Skill = {
  id: "auto_attack_hunter",
  name: "Flechada",
  level: 1,
  baseDamage: 2,
  area: 0,
  animation: "AutoAttack",
  effect: "ArrowShot",
  characterClass: "Hunter",
  description: "Atira uma flecha no alvo.",
}

export const AutoAttackMage: Skill = {
  id: "auto_attack_mage",
  name: "Bola de Fogo",
  level: 1,
  baseDamage: 4,
  area: 0,
  animation: "CastAutoAttack",
  effect: "Fireball",
  characterClass: "Mage",
  description: "Lança uma bola de fogo explosiva no alvo.",
}