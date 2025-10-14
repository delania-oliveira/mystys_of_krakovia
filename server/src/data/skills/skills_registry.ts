import { skills, registerSkill } from "./skills";
import { DefaultSkillArcher, DefaultSkillMage } from "./auto_attack";
import { ArcaneExplosionMage } from "./arcane_explosion";
import { MultiShotArcher } from "./multi_shot";
import { FlameArrowArcher } from "./flame_arrow";

registerSkill(DefaultSkillArcher);
registerSkill(MultiShotArcher)
registerSkill(FlameArrowArcher)

registerSkill(DefaultSkillMage);
registerSkill(ArcaneExplosionMage)

export { skills };