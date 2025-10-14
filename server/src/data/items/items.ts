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
    name: "Jaqueta de Pano",
    defense: 1,
    description: "Uma jaqueta de pano básica.",
    type: "Armor",
    limitedClasses: ["Todas"],
  },
  "3": {
    id: 3,
    name: "Jaqueta de Couro",
    defense: 4,
    description: "Uma jaqueta de couro básica.",
    type: "Armor",
    limitedClasses: ["Archer", "Assassin", "Warrior"],
  },
  "4": {
    id: 4,
    name: "Cota de Malha",
    defense: 6,
    description: "Uma armadura pesada feita de correntes utilizada pelos guerreiros.",
    type: "Armor",
    limitedClasses: ["Warrior"],
  },
  "5": {
    id: 5,
    name: "Jaqueta de Seda",
    defense: 3,
    description: "Uma jaqueta de seda utilizada por magos.",
    type: "Armor",
    limitedClasses: ["Todas"],
  },
  "6": {
    id: 6,
    name: "Capuz de Seda",
    defense: 2,
    description: "Um capuz de seda utilizada por magos.",
    type: "Helmet",
    limitedClasses: ["Todas"],
  },
  "7": {
    id: 7,
    name: "Capuz de Couro",
    defense: 3,
    description: "Um capuz de couro utilizado por assassinos e arqueiros.",
    type: "Helmet",
    limitedClasses: ["Archer", "Assassin", "Warrior"],
  },
  "8": {
    id: 8,
    name: "Capuz de Malha",
    defense: 4,
    description: "Um capuz de malha utilizado por guerreiros.",
    type: "Helmet",
    limitedClasses: ["Warrior"],
  }
}