import { skills, registerSkill } from "./skills";
import { DefaultSkillArcher, DefaultSkillMage } from "./auto_attack";
import { ArcaneExplosionMage } from "./arcane_explosion";
import { MultiShotArcher } from "./multi_shot";

registerSkill(DefaultSkillArcher);
registerSkill(DefaultSkillMage);
registerSkill(ArcaneExplosionMage)
registerSkill(MultiShotArcher)

export { skills };