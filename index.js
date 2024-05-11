const { WebSocketServer, WebSocket } = require("ws");

const wss = new WebSocketServer({ port: 8080 });

wss.on("connection", (ws) => {
    const discord = new WebSocket("wss://gateway.discord.gg/?v=10&encoding=json");
    let heart;
    let s = null;
    let acknowledged = true;

    ws.on("error", console.error);
    ws.on("close", () => {
        discord.close();
        clearInterval(heart);
    });
    ws.on("message", (raw) => {
        console.log(`[SENT] ${raw}`);

        discord.send(raw);
    });

    discord.on("close", (code, reason) => {
        ws.close();
        clearInterval(heart);
        console.log(`[DISCORD CLOSED] ${reason}`);
    });
    discord.on("error", console.error);
    discord.on("message", (raw) => {
        const data = JSON.parse(raw);
        console.log(`[RECEIVED] ${raw}`);

        if (data.s)
            s = data.s;

        switch (data.op) {
            case 10: {
                const heartbeatInterval = data.d.heartbeat_interval;
                const timer = heartbeatInterval * Math.random();

                console.log(`Waiting ${timer}ms.`);

                heart = setTimeout(() => {
                    heartbeat(discord, s);
                    setInterval(() => heartbeat(discord, s), heartbeatInterval);
                }, heartbeatInterval * Math.random());
                break;
            }
            case 1: {
                heartbeat(discord, s);
                break;
            }
            case 11: {
                acknowledged = true;
                break;
            }
        }

        ws.send(raw);
    });

    function heartbeat() {
        if (!acknowledged) {
            console.log("Didn't receive heartbeat acknowledgement? Closing!");
            clearInterval(heart);
            discord.close();
            ws.close();
        }

        discord.send(JSON.stringify({
            op: 1,
            d: s
        }));

        acknowledged = false;
    }
});
