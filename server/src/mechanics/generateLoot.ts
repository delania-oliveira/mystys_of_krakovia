import { Monster } from "../rooms/schema/Monster";
import { LootTable } from "../data/monsters/monsters_loot/loot_tables";
import { DroppedItems } from "../data/items/item_type";
export function generateLoot(monster: Monster){
  const loot: DroppedItems[] = []
  const lootEntries = LootTable[monster.name];
  if (!lootEntries) return loot;
  for (const entry of lootEntries) {
    const quantity =
      Math.floor(Math.random() * (entry.max_quantity - entry.min_quantity + 1)) +
      entry.min_quantity;
    if (Math.floor(Math.random() * 100) <= entry.chance) {
      loot.push({
        id: entry.id,
        name: entry.name,
        quantity: quantity,
      });
    }
  }
  return loot
}