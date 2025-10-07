export interface Skill {
  id: string
  name: string
  baseDamage: number
  area: number
  animation: string
  effect: string
}

export const skills = new Map<string, Skill>();

export function registerSkill(skill: Skill) {
  skills.set(skill.id, skill);
}