#!/bin/bash

mix phx.gen.schema User users \
  avatar_url:string \
  avatar_origin:string \
  username:string \
  email:string \
  name:string \
  password_hash:string \
  last_online_at:utc_datetime \
  active:boolean \
  banned:boolean

sleep 1

mix phx.gen.schema Contact contacts \
  owner_id:references:users \
  user_id:references:users \
  name:string \
  blacklisted:boolean

sleep 1

mix phx.gen.schema Chat chats \
  type:string \
  last_event_at:utc_datetime \
  active:boolean \
  banned:boolean \
  data:map

sleep 1

mix phx.gen.schema Membership memberships \
  user_id:references:users \
  chat_id:references:chats \
  active:boolean \
  banned:boolean \
  denied:boolean \
  pin_order:integer \
  owner:boolean \
  moderator:boolean \

sleep 1

mix phx.gen.schema Message messages \
  author_id:references:users \
  chat_id:references:chats \
  origin_id:references:chats \
  type:string \
  content:map

sleep 1

mix phx.gen.schema File files \
  filename:string \
  url:string \
  type:string

sleep 1

mix phx.gen.schema StickerPack stickerpacks \
  title:string \
  author_id:references:users \
  hide_author:boolean

sleep 1

mix phx.gen.schema Sticker stickers \
  stickerpack:references:stickerpacks \
  url:string \
  message:string

sleep 1

mix phx.gen.schema MessageRead message_reads \
  user_id:references:users \
  message_id:references:messages

sleep 1

mix phx.gen.schema Blacklist blacklists \
  owner_id:references:users \
  user_id:references:users