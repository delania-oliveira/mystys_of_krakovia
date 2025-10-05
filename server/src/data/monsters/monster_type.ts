export interface MonsterType {
  id: string;
  name: string;
  type: string;
  hp: number;
  attack: number;
  defense: number;
  speed: number;
  x: number;
  y: number;
  z: number;
}

export interface MonstersXML {
  monsters: {
    monster: MonsterType[];
  };
}