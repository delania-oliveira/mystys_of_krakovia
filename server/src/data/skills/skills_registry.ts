import { skills, registerSkill } from "./skills";
import { DefaultSkillArcher, DefaultSkillMage } from "./auto_attack";

registerSkill(DefaultSkillArcher);
registerSkill(DefaultSkillMage);

export { skills };