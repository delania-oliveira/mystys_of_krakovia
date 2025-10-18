import { PossibleItems } from "../../items/item_type";

export const LootTable: Record<string, PossibleItems[]> = {
  Goblin: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 3, name: "Jaqueta de Pano", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 12 },
    { id: 6, name: "Capuz de Seda", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 16, name: "Arco Composto", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
  ],
  Esqueleto: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 2, name: "Jaqueta de Pano", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 5, name: "Jaqueta de Seda", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 4, name: "Cota de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
  ],
  "Esqueleto Pirata": [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 10, name: "Espada Larga", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 4, name: "Cota de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
  ],
  Bandit: [
    { id: 1, name: "Ouro", min_quantity: 25, max_quantity: 50, quantity: 0, chance: 100 },
    { id: 4, name: "Cota de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
    { id: 8, name: "Capuz de Malha", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
  ],
  Lobo: [
    { id: 9, name: "Cimitarra", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 15, name: "Arco Simples", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
    { id: 12, name: "Cajado Simples", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 15 },
  ],
  Beholder: [
    { id: 12, name: "Cajado Simples", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 25 },
    { id: 13, name: "Cajado de Cristal", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 10 },
    { id: 14, name: "Sangue de Krakovia", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 5 },
  ],
  "Selvara Nocthyra": [
    { id: 14, name: "Sangue de Krakovia", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 100 },
    { id: 1, name: "Gold", min_quantity: 150, max_quantity: 1000, quantity: 1, chance: 100 },
  ],
  "Galdurg o Obliterador": [
    { id: 11, name: "Espada do Senhor da Guerra", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 25 },
    { id: 17, name: "Luar de Ithil", min_quantity: 1, max_quantity: 1, quantity: 1, chance: 25 },
  ],
};
