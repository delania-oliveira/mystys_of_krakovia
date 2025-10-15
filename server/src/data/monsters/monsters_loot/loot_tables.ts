import { PossibleItems } from "../../items/item_type";

export const LootTable: Record<string, PossibleItems[]> = {
  Rat: [
    { id: 1, name: "Ouro", min_quantity: 1, max_quantity: 20, quantity: 0, chance: 100 },
  ],
  Orc: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 100, quantity: 0, chance: 100 },
    { id: 3, name: "Jaqueta de Couro", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
    { id: 7, name: "Capuz de Couro", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 5 },
  ],
  Goblin: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 3, name: "Jaqueta de Pano", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 100 },
    { id: 6, name: "Capuz de Seda", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 100 },
  ],
  Skeleton: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 2, name: "Jaqueta de Pano", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 25 },
    { id: 5, name: "Jaqueta de Seda", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 25 },
  ],
  Troll: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 4, name: "Cota de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 50 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 50 },
  ],
  Bandit: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 4, name: "Cota de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
  ],
  Ogre: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 5, name: "Jaqueta de Seda", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
  ],
};
