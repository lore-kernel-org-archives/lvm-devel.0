From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Thu, 12 Oct 2023 13:49:48 +0200
Subject: Reg lvmcache and cache drain
In-Reply-To: <CAFe+wq26RaHMPsC_nN+60ycQBAJYtR9Y9CQV=w89RkiwKOgY-g@mail.gmail.com>
References: <CAFe+wq26RaHMPsC_nN+60ycQBAJYtR9Y9CQV=w89RkiwKOgY-g@mail.gmail.com>
Message-ID: <77c3a7dc-e9c5-4157-a3fc-87e46c636c17@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11. 10. 23 v 6:14 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> A very good day to you all.
> I am looking at your inputs to effectively configure cache to drain at
> max speed while being online.
> 
> I have a setup with lvm cache, writeback, smq, migration threshold to
> support 100 cache blocks to start with (that gets relaxed to higher
> values as dirty blocks increase). This cache device is operating near
> full and switched to cleaner policy to enable effective cache drain of
> dirty blocks.
> 
> But the observation is as follows.
> 1/ given cache is in writeback mode and online, newer IOs effectively
> create new dirty blocks.
> 
> 2/ incoming IOs to cache device do seem to have higher precedence vs
> IO migration of dirty data from within cache to origin. Effectively
> migration kick starts only from one level within (lru logic within)
> when cache/origin is not idle. This effectively limits the clean
> transition rate irrespective of the migration threshold.
> 
> 3/ switching cache to writethrough effectively blocks the cli forever
> and still the migration is not fast enough. Only taking the IO
> offline, i.e. device should be IDLE within, triggers that burst of
> migrations.

Hi

Not clear which combination has been actually tested - but to quickly drain 
cache, it should be switched to cleaner policy  (that within lvm should 
automatically switches also a caching mode to 'writethrough'.

So if your 'draining' also switching to cleaner cache policy from smq.  ?

Can you provide a bit more context with timing information and DM table line 
and DM status lines from your testing so we could more easily understand this 
issue ?

Also show the kernel versions in use - was this vanilla ?

Thanks

Zdenek

