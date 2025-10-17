import { Skill } from "./skills"

export const FlameArrowArcher: Skill = {
  id: "flame_arrow_archer",
  name: "Flecha de Fogo",
  level: 1,
  baseDamage: 20,
  range: 30,
  area: 0,
  animation: "AttackFlameArrow",
  effect: "FlameArrow",
  characterClass: "Archer",
  description: "Dispara uma flecha envolta em chamas ardentes, consumindo tudo em seu caminho",
  needTarget: true,
  cooldown: 10.0,
  manaCost: 35
}
