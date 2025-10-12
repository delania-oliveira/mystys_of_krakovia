export interface Skill {
  id: string
  name: string
  level: number
  baseDamage: number
  range: number
  area: number
  animation: string
  effect: string
  characterClass: string
  description: string
}

export const skills = new Map<string, Skill>();

export function registerSkill(skill: Skill) {
  skills.set(skill.id, skill);
}

export function getSkillsByClass(className: string): Skill[] {
  return Array.from(skills.values()).filter(
    (skill) => skill.characterClass === className
  ).toSorted((a, b) => a.level - b.level);
}