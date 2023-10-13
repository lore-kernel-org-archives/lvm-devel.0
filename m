From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 13 Oct 2023 13:03:13 +0200
Subject: Reg lvmcache and cache drain
In-Reply-To: <CAFe+wq0ih=Vb=i1KEN9s0uf8hs9ThT9CZTSFy1m0xHS2GJuO=Q@mail.gmail.com>
References: <CAFe+wq26RaHMPsC_nN+60ycQBAJYtR9Y9CQV=w89RkiwKOgY-g@mail.gmail.com>
 <77c3a7dc-e9c5-4157-a3fc-87e46c636c17@gmail.com>
 <CAFe+wq0ih=Vb=i1KEN9s0uf8hs9ThT9CZTSFy1m0xHS2GJuO=Q@mail.gmail.com>
Message-ID: <7b3836a6-0fa5-419c-b34b-cfdb8e32ff16@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12. 10. 23 v 18:39 Lakshmi Narasimhan Sundararajan napsal(a):
> Thanks Zdenek, below are my replies.
> 
>> Not clear which combination has been actually tested - but to quickly drain
> cache, it should be switched to cleaner policy  (that within lvm should
> automatically switches also a caching mode to 'writethrough'.
> 
> Yes cache policy switches to "cleaner" with higher
> migration_threshold. While IO continues to hit the cache device,
> write/read hits counter also increases and dirty block counter does
> not show much difference. So my reading was newer IOs continue to

Hi

Looking at table lines the configuration is far from being optimal.
There are several things that may cause considerable slowdown.

1.)  placing thin-pool data & metadata on the same 'drive' and 
caching/accelerating only  'tdata' volume is likely slowing down whole 
thin-pool in major way.

As a rule #1 you should always place _tmeta on the fastest drive you have
(and you may 'raid1' there if can on that fast storage). Also you should not 
try to 'cache' _tmeta - you should allocated _tmeta on your fastest drive you 
use for caching.

2.) decommissioning of blocks from cache of 1MiB in size each - basically 
makes some load on your 'raid'  md125 drive - and now it's a big question how 
big load your backing drive can handle when there is a lot of seeking going in 
(as blocks are likely not streamed from cache from the most optimal way to 
minimize seeks - but rather in some 'timing' order - as there is never 
targeted the 'maximal' speed of uncaching - as primary goal is caching ;)

So here you likely need to 'measure' some realistic numbers of 'fragmented' 
writes aka - do not compare this with maximal  'dd' throughput you can have 
with your md125 - rather check with some 'fio' workload.

3.) your device volume sizes are 'massive' - so if you plan to fully 
'synchronize' your backend device more frequently - simply use smaller cache 
size to avoid long time of uncaching.

4.) if you primary goal is to accelerate 'write' performance - there is also 
writecache that is more targeted to kind of extend your 'dirty cache page size 
buffer'  instead of doing  a hot-spot caching.

5.) There is visible 'misalignment' of your thin-pool chunk size (1088MiB) 
(like take to match alignment of you 'raid' md125 drive) and you cache blocks 
- where blocks are likely 'overlapping' in suboptimal way - thus smaller 
cache-blocks would certainly do a better work - this may cause some 
significant performance penalty on uncaching side.
(Possibly here could even lvm2 try to make a better job).

6.) If you snapshots with thin-pool - I'd consider smaller tpool chunksize 
(aka lvm2 picks blindly some 'defaults' - but knowledgeable admin can 
certainly do better job - especially when we are at the sizes you have  245TiB)

Hopefully this will give you some idea how to enhance your storage stack.

Regards

Zdenek

