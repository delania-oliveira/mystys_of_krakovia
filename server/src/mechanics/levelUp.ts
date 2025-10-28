import { Player } from "../rooms/schema/Player";

export function levelUp(player: Player) {
  player.level += 1
  player.attack += 1
  player.defense += 1
  switch (player.character_class) {
    case "Warrior":
      player.max_health += 25
      player.max_mana += 5
      break;
    case "Archer":
      player.max_health += 10
      player.max_mana += 10
      break;
    case "Mage":
      player.max_health += 5
      player.max_mana += 20
      break;
    case "Blood Mage":
      player.max_health += 20;
      break;
    default:
      break;
  }
  player.health = player.max_health
}
