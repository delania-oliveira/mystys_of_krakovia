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
  description: "Concentra pura energia arcana em um ponto e a libera em uma poderosa explosão mágica",
  castTime: 2.0,
  needTarget: false,
  cooldown: 0,
  manaCost: 20
}
