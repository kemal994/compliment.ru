from userbot import CMD_HELP
from userbot.events import register
from .compliments_data import COMPLIMENTS
import asyncio

task = None
index = 0
running = False

@register(outgoing=True, pattern=r"\.compliment$")
async def compliment_start(event):
    global task, index, running

    if running:
        running = False
        if task:
            task.cancel()
        await event.edit("🛑 Остановлено")
        return

    index = 0
    running = True
    task = asyncio.create_task(send_compliments(event))
    await event.edit("✅ Запущено! Комплименты каждые 10 сек\n.compliment чтобы остановить")

async def send_compliments(event):
    global index, running
    try:
        while running:
            comp = COMPLIMENTS[index % len(COMPLIMENTS)]
            await event.respond(f"✨ {comp}")
            index += 1
            await asyncio.sleep(10)
    except:
        pass

@register(outgoing=True, pattern=r"\.compliment_rotate (\d+)$")
async def compliment_rotate(event):
    global task, index, running

    minutes = int(event.pattern_match.group(1))

    if running:
        running = False
        if task:
            task.cancel()

    index = 0
    running = True
    task = asyncio.create_task(rotate_compliments(event, minutes))
    await event.edit(f"✅ Запущено! Интервал: {minutes} мин")

async def rotate_compliments(event, minutes):
    global index, running
    try:
        while running:
            comp = COMPLIMENTS[index % len(COMPLIMENTS)]
            await event.respond(f"🔄 {comp}")
            index += 1
            await asyncio.sleep(minutes * 60)
    except:
        pass

@register(outgoing=True, pattern=r"\.stop_comp$")
async def stop_compliment(event):
    global running, task
    running = False
    if task:
        task.cancel()
    await event.edit("🛑 Остановлено")

CMD_HELP.update({
    "compliment": 
    "`.compliment` - комплименты каждые 10 сек (еще раз = стоп)\n"
    "`.compliment_rotate 5` - каждые 5 минут\n"
    "`.stop_comp` - остановить"
})
