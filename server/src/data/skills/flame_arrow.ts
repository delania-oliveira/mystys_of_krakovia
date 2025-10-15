import { Skill } from "./skills"

export const FlameArrowArcher: Skill = {
  id: "flame_arrow_archer",
  name: "Flecha de Fogo",
  level: 10,
  baseDamage: 20,
  range: 30,
  area: 0,
  animation: "AttackFlameArrow",
  effect: "FlameArrow",
  characterClass: "Archer",
  description: "Atira uma flecha de fogo no alvo",
  needTarget: true,
  cooldown: 10.0
}
