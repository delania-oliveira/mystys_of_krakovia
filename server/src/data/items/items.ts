import { Item } from "./item_type";

export const items: Record<string, Item> = {
  "1": {
    id: 1,
    name: "Ouro",
    description: "",
    type: "Currency",
    rarity: "Comum"
  },
  "2": {
    id: 2,
    name: "Jaqueta de Pano",
    defense: 1,
    description: "Uma jaqueta de pano básica.",
    type: "Armor",
    limitedClasses: ["Todas"],
    rarity: "Comum"
  },
  "3": {
    id: 3,
    name: "Jaqueta de Couro",
    defense: 4,
    description: "Uma jaqueta de couro básica.",
    type: "Armor",
    limitedClasses: ["Archer", "Assassin", "Warrior"],
    rarity: "Comum"
  },
  "4": {
    id: 4,
    name: "Cota de Malha",
    defense: 6,
    description: "Uma armadura pesada feita de correntes utilizada pelos guerreiros.",
    type: "Armor",
    limitedClasses: ["Warrior"],
    rarity: "Comum"
  },
  "5": {
    id: 5,
    name: "Jaqueta de Seda",
    defense: 3,
    description: "Uma jaqueta de seda utilizada por magos.",
    type: "Armor",
    limitedClasses: ["Todas"],
    rarity: "Comum"
  },
  "6": {
    id: 6,
    name: "Capuz de Seda",
    defense: 2,
    description: "Um capuz de seda utilizada por magos.",
    type: "Helmet",
    limitedClasses: ["Todas"],
    rarity: "Incomum"
  },
  "7": {
    id: 7,
    name: "Capuz de Couro",
    defense: 3,
    description: "Um capuz de couro utilizado por assassinos e arqueiros.",
    type: "Helmet",
    limitedClasses: ["Archer", "Assassin", "Warrior"],
    rarity: "Incomum"
  },
  "8": {
    id: 8,
    name: "Capuz de Malha",
    defense: 4,
    description: "Um capuz de malha utilizado por guerreiros.",
    type: "Helmet",
    limitedClasses: ["Warrior"],
    rarity: "Incomum"
  },
  "9": {
    id: 9,
    name: "Cimitarra",
    attack: 3,
    description: "Uma lâmina curva e afiada, leve o bastante para golpes rápidos e precisos.",
    type: "Weapon",
    limitedClasses: ["Warrior"],
    rarity: "Comum"
  },
  "10": {
    id: 10,
    name: "Espada Larga",
    attack: 5,
    description: "Pesada e mortal, esta lâmina larga impõe respeito em qualquer campo de batalha.",
    type: "Weapon",
    limitedClasses: ["Warrior"],
    rarity: "Incomum"
  },
  "11": {
    id: 11,
    name: "Espada do Senhor da Guerra",
    attack: 10,
    description: "Forjada para comandar exércitos, esta lâmina colossal carrega o peso de incontáveis batalhas vencidas.",
    type: "Weapon",
    limitedClasses: ["Warrior"],
    rarity: "Lendário"
  },
  "12": {
    id: 12,
    name: "Cajado Simples",
    attack: 3,
    description: "Cajado de madeira simples, utilizado por magos iniciantes.",
    type: "Weapon",
    limitedClasses: ["Mage"],
    rarity: "Comum"
  },
  "13": {
    id: 13,
    name: "Cajado de Cristal",
    attack: 5,
    description: "O cristal em seu topo brilha com energia arcana, canalizando o poder dos elementos.",
    type: "Weapon",
    limitedClasses: ["Mage"],
    rarity: "Épico"
  },
  "14": {
    id: 14,
    name: "Sangue de Krakovia",
    attack: 10,
    description: "No topo do cajado brilha um cristal vermelho como sangue, fonte de um poder ancestral e incontrolável.",
    type: "Weapon",
    limitedClasses: ["Mage"],
    rarity: "Lendário"
  },
}