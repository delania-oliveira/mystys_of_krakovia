import { PossibleItems } from "../../items/item_type";

export const LootTable: Record<string, PossibleItems[]> = {
  Rat: [
    { id: 1, name: "Gold Coin", min_quantity: 1, max_quantity: 42, quantity: 0 },
  ],
  Orc: [
    { id: 1, name: "Gold Coin", min_quantity: 25, max_quantity: 100, quantity: 0 },
  ],
};
