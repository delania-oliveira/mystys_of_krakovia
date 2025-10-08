import { skills, registerSkill } from "./skills";
import { AutoAttackHunter, AutoAttackMage } from "./auto_attack";

registerSkill(AutoAttackHunter);
registerSkill(AutoAttackMage);

export { skills };