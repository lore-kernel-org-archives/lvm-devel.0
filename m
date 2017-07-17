From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:17 -0400
Subject: master - clvmd: fix valgrind memory report
Message-ID: <201707171140.v6HBeHkO022512@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28e319ddc0cf3f60ee200a2c4a0bab971e1490c8
Commit:        28e319ddc0cf3f60ee200a2c4a0bab971e1490c8
Parent:        d7f92ea8ee71997027007088beaf342c625abb44
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 12:25:05 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:30:01 2017 +0200

clvmd: fix valgrind memory report

Avoid reading already released memory and do a continue directly.

Invalid read of size 1
   at 0x1201B0: main_loop (clvmd.c:931)
   by 0x11F640: main (clvmd.c:666)
 Address 0x72ddef0 is 32 bytes inside a block of size 224 free'd
   at 0x4C30D18: free (vg_replace_malloc.c:530)
   by 0x54D6FD1: dm_free_wrapper (dbg_malloc.c:357)
   by 0x122E6E: process_work_item (clvmd.c:2034)
   by 0x123003: lvm_thread_fn (clvmd.c:2085)
   by 0x590A3A8: start_thread (pthread_create.c:465)
   by 0x5C3C7FE: clone (in /usr/lib64/libc-2.25.90.so)
 Block was alloc'd at
   at 0x4C2FB6B: malloc (vg_replace_malloc.c:299)
   by 0x54D6EF1: dm_malloc_aux (dbg_malloc.c:286)
   by 0x54D6F1C: dm_zalloc_aux (dbg_malloc.c:291)
   by 0x54D6F96: dm_zalloc_wrapper (dbg_malloc.c:345)
   by 0x11F89C: local_rendezvous_callback (clvmd.c:731)
   by 0x1203D2: main_loop (clvmd.c:964)
   by 0x11F640: main (clvmd.c:666)
---
 daemons/clvmd/clvmd.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 0832f4a..7506dca 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -925,6 +925,7 @@ static void main_loop(int cmd_timeout)
 
 				/* Queue cleanup, this also frees the client struct */
 				add_to_lvmqueue(thisfd, NULL, 0, NULL);
+				continue;
 			}
 
 			if (thisfd->removeme)


