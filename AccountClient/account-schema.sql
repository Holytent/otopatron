-- Supabase SQL Editor: run once. Users can only read their own save.
create table if not exists public.game_saves (
 user_id uuid primary key references auth.users(id) on delete cascade,
 snapshot jsonb not null,
 revision bigint not null default 1,
 updated_at timestamptz not null default now()
);
alter table public.game_saves enable row level security;
drop policy if exists own_save_read on public.game_saves;
create policy own_save_read on public.game_saves for select to authenticated using ((select auth.uid())=user_id);
revoke all on public.game_saves from anon, authenticated;
grant select on public.game_saves to authenticated;
create or replace function public.put_game_save(p_snapshot jsonb,p_revision bigint)
returns bigint language plpgsql security definer set search_path='' as $$
declare uid uuid:=auth.uid(); next_revision bigint;
begin
 if uid is null then raise exception 'not_authenticated'; end if;
 if jsonb_typeof(p_snapshot)<>'object' or pg_column_size(p_snapshot)>262144
   or not (p_snapshot ? 'version' and p_snapshot ? 'cars' and p_snapshot ? 'money')
 then raise exception 'invalid_save'; end if;
 if p_revision=0 then
   insert into public.game_saves(user_id,snapshot) values(uid,p_snapshot)
     on conflict do nothing returning revision into next_revision;
 else
   update public.game_saves set snapshot=p_snapshot,revision=revision+1,updated_at=now()
     where user_id=uid and revision=p_revision returning revision into next_revision;
 end if;
 if next_revision is null then raise exception 'save_conflict'; end if;
 return next_revision;
end; $$;
revoke all on function public.put_game_save(jsonb,bigint) from public,anon;
grant execute on function public.put_game_save(jsonb,bigint) to authenticated;
