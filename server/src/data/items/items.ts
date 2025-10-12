import { Item } from "./item_type";

export const items: Record<string, Item> = {
  "1": {
    id: 1,
    name: "Ouro",
    description: "",
    type: "Currency"
  },
  "2": {
    id: 2,
    name: "Jaqueta de Couro",
    defense: 1,
    description: "Uma jaqueta de couro básica.",
    type: "Armor"
  }
}