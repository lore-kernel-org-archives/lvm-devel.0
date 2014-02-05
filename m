From: Paul B. Henson <henson@acm.org>
Date: Tue, 4 Feb 2014 17:51:40 -0800
Subject: cache support
Message-ID: <096101cf2214$d241ed60$76c5c820$@acm.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So I was browsing through the last month or so of list archives and
reviewing the cache support under development, and had a question regarding
use cases. Unless I am misunderstanding, it looks like the support being
built so far addresses the use case of taking two lv's (a large slow origin
lv and a small fast cache lv) and combining them into a third lv.

Is there any intention to support a use case where you can attach a cache to
the underlying pv, and have every single lv created on that pv cached? On a
virtualization server I'm working on, I have an md raid1 of two 256G SSD's,
and an md raid10 of four 2TB hard drives. What I'd like to do is create a
cache device consisting of those two raid devices, and create a pv/vg on top
of that. I know that is possible with the raw underlying dm-cache
implementation, but it didn't look like the initial code dropped in lvm so
far would support something like that?

Thanks.


