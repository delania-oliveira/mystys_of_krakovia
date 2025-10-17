import { skills, registerSkill } from "./skills";
import { DefaultSkillArcher, DefaultSkillMage, DefaultSkillWarrior } from "./auto_attack";
import { ArcaneExplosionMage } from "./arcane_explosion";
import { MultiShotArcher } from "./multi_shot";
import { FlameArrowArcher } from "./flame_arrow";
import { DesintegrateMage } from "./desintegrate";
import { CleaveAttackWarrior } from "./cleave";
import { WarcryWarrior } from "./warcry";

registerSkill(DefaultSkillArcher);
registerSkill(MultiShotArcher)
registerSkill(FlameArrowArcher)

registerSkill(DefaultSkillMage);
registerSkill(ArcaneExplosionMage)
registerSkill(DesintegrateMage)

registerSkill(DefaultSkillWarrior)
registerSkill(CleaveAttackWarrior)
registerSkill(WarcryWarrior)
export { skills };