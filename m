From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 05 Feb 2014 10:35:06 +0100
Subject: cache support
In-Reply-To: <096101cf2214$d241ed60$76c5c820$@acm.org>
References: <096101cf2214$d241ed60$76c5c820$@acm.org>
Message-ID: <52F205CA.1090807@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.2.2014 02:51, Paul B. Henson napsal(a):
> So I was browsing through the last month or so of list archives and
> reviewing the cache support under development, and had a question regarding
> use cases. Unless I am misunderstanding, it looks like the support being
> built so far addresses the use case of taking two lv's (a large slow origin
> lv and a small fast cache lv) and combining them into a third lv.
>
> Is there any intention to support a use case where you can attach a cache to
> the underlying pv, and have every single lv created on that pv cached? On a
> virtualization server I'm working on, I have an md raid1 of two 256G SSD's,
> and an md raid10 of four 2TB hard drives. What I'd like to do is create a
> cache device consisting of those two raid devices, and create a pv/vg on top
> of that. I know that is possible with the raw underlying dm-cache
> implementation, but it didn't look like the initial code dropped in lvm so
> far would support something like that?


Well - there is work in progress in upstream git - but it's highly 
'experimental' and its user-space API can change any minute - so it's only 
useful for playing - but not for any real use yet.

The device stacking is getting quite complex.

Side note - lvm2 now supports it's own metadata format for md raid1 - this 
should allow better handling of device stack (it's using same kernel driver as 
mdraid) - use just a single command to active everything in proper order.

Current version of dm-cache supports  only  1:1 mapping - so one large cache 
shared by multiple LVs is not supported. You will need to prepare smaller 
individual cache pools for each of your LV.

lvm2 side is designed to allow to play with more different cache targets in 
future.

Zdenek


