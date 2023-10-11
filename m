From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 11 Oct 2023 09:44:56 +0530
Subject: Reg lvmcache and cache drain
Message-ID: <CAFe+wq26RaHMPsC_nN+60ycQBAJYtR9Y9CQV=w89RkiwKOgY-g@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team,
A very good day to you all.
I am looking at your inputs to effectively configure cache to drain at
max speed while being online.

I have a setup with lvm cache, writeback, smq, migration threshold to
support 100 cache blocks to start with (that gets relaxed to higher
values as dirty blocks increase). This cache device is operating near
full and switched to cleaner policy to enable effective cache drain of
dirty blocks.

But the observation is as follows.
1/ given cache is in writeback mode and online, newer IOs effectively
create new dirty blocks.

2/ incoming IOs to cache device do seem to have higher precedence vs
IO migration of dirty data from within cache to origin. Effectively
migration kick starts only from one level within (lru logic within)
when cache/origin is not idle. This effectively limits the clean
transition rate irrespective of the migration threshold.

3/ switching cache to writethrough effectively blocks the cli forever
and still the migration is not fast enough. Only taking the IO
offline, i.e. device should be IDLE within, triggers that burst of
migrations.

4/ If the app (io generator) is taken offline, cache drains at  a very
fast rate.

It seems near impossible to effectively drain dirty cache while being online.
Is there a way to accomplish the following:
a) initiate migration of all dirty data from cache without looking at LRU age
b) utilize max migration bandwidth setup to origin in addition to new IO.
c) do not create new dirty blocks even while operating in writeback
mode with cleaner policy.

What would be the most optimal way to accomplish this?

Thanks
LN

