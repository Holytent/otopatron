// At most one message per scheduler tick; delayed ticks never replay missed slots.
export function nextReminder(player, now, gaps) {
  const previous = player.spacedReminder;
  if (!previous || previous.session !== player.lastSeen) {
    return {session:player.lastSeen,index:0,dueAt:Math.max(player.lastSeen,player.lastSent||0)+gaps[0]*60000};
  }
  return previous;
}
export function advanceReminder(state, now, gaps) {
  const index=(state.index+1)%gaps.length;
  return {...state,index,dueAt:now+gaps[index]*60000};
}
