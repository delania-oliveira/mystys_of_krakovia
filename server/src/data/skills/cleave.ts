import { Skill } from "./skills";

export const CleaveAttackWarrior: Skill = {
  id: "cleave_attack_warrior",
  name: "Rachar",
  level: 1,
  baseDamage: 5,
  range: 10,
  area: 5,
  animation: "Ataque Pesado",
  effect: "CleaveAttackMelee",
  characterClass: "Warrior",
  description: "Executa um ataque em arco que causa dano a todos os inimigos em uma área frontal.",
  needTarget: true,
  cooldown: 0,
  manaCost: 5
}