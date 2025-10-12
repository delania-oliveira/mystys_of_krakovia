import { PossibleItems } from "../../items/item_type";

export const LootTable: Record<string, PossibleItems[]> = {
  Rat: [
    { id: 1, name: "Ouro", min_quantity: 1, max_quantity: 42, quantity: 0 },
  ],
  Orc: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 100, quantity: 0 },
    { id: 2, name: "Jaqueta de Couro", min_quantity: 1, max_quantity: 1, quantity: 1 },
  ],
};
