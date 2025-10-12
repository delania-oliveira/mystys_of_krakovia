export interface PossibleItems {
  id: number;
  name: string;
  min_quantity: number;
  max_quantity: number;
  quantity: number;
}

export interface DroppedItems {
  id: number,
  name: string,
  quantity: number
}

export interface Item {
  id: number,
  name: string,
  description?: string
  defense?: number,
  attack?: number,
  type: string
}