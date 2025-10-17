export interface MonsterType {
  id: string;
  name: string;
  type: string;
  health: number;
  attack: number;
  defense: number;
  speed: number;
  x: number;
  y: number;
  z: number;
  detection_range: number;
  difficulty: number;
  experience: number;
  respawn: number;
  attack_range: number
}

export interface MonstersXML {
  monsters: {
    monster: MonsterType[];
  };
}