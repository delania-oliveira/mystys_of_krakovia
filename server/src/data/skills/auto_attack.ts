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
  needTarget: true,
  cooldown: 0,
  manaCost: 0
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
  needTarget: true,
  cooldown: 0,
  manaCost: 5
}

export const DefaultSkillWarrior: Skill = {
  id: "default_skill_warrior",
  name: "Ataque Leve",
  level: 1,
  baseDamage: 2,
  range: 5,
  area: 0,
  animation: "Ataque Leve",
  effect: "DefaultAttackMelee",
  characterClass: "Warrior",
  description: "Um ataque simples e direto com a lâmina.",
  needTarget: true,
  cooldown: 0,
  manaCost: 0
}

export const DefaultSkillBloodMage: Skill = {
  id: "default_skill_blood_mage",
  name: "Espinho de Sangue",
  level: 1,
  baseDamage: 5,
  range: 25,
  area: 0,
  animation: "DefaultCast",
  effect: "BloodSpike",
  characterClass: "Blood Mage",
  description: "Converte parte de sua própria vida em energia, causando dano nos inimigos ou restaurando a saúde dos aliados ao custo do próprio sangue.",
  needTarget: true,
  cooldown: 0,
  castTime: 1.0,
  manaCost: 5,
  healing: 10
}
