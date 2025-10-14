import { Skill } from "./skills"

export const ArcaneExplosionMage: Skill = {
  id: "arcane_explosion_mage",
  name: "Explosão Arcana",
  level: 3,
  baseDamage: 10,
  range: 0,
  area: 10,
  animation: "ArcaneExplosionCast",
  effect: "ArcaneExplosion",
  characterClass: "Mage",
  description: "Explosão arcana.",
  castTime: 2.0,
  needTarget: false
}
