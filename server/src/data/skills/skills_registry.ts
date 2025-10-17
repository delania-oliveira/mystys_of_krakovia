import { skills, registerSkill } from "./skills";
import { DefaultSkillArcher, DefaultSkillBloodMage, DefaultSkillMage, DefaultSkillWarrior } from "./auto_attack";
import { ArcaneExplosionMage } from "./arcane_explosion";
import { MultiShotArcher } from "./multi_shot";
import { FlameArrowArcher } from "./flame_arrow";
import { DesintegrateMage } from "./desintegrate";
import { CleaveAttackWarrior } from "./cleave";
import { WarcryWarrior } from "./warcry";
import { SpillBloodBloodMage } from "./spill_blood";
import { DrainLifeBloodMage } from "./drain_life";

registerSkill(DefaultSkillArcher);
registerSkill(MultiShotArcher)
registerSkill(FlameArrowArcher)

registerSkill(DefaultSkillMage);
registerSkill(ArcaneExplosionMage)
registerSkill(DesintegrateMage)

registerSkill(DefaultSkillWarrior)
registerSkill(CleaveAttackWarrior)
registerSkill(WarcryWarrior)

registerSkill(DefaultSkillBloodMage)
registerSkill(SpillBloodBloodMage)
registerSkill(DrainLifeBloodMage)

export { skills };