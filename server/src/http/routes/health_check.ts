import { matchMaker } from "colyseus";
import { Router } from "express";

const router = Router()

router.get("/health_check/:roomName", async (req, res) => {
    const rooms = await matchMaker.query({ name: req.params.roomName })
    if (rooms.length > 0) {
        res.status(200).json({ players: rooms[0].clients, max: rooms[0].maxClients })
    } else {
        res.status(404).json({ players: 0, max: 0 })
    }
});

export default router