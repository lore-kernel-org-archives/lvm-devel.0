From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:35 +0000 (GMT)
Subject: main - lvmcache: fix memory leak
Message-ID: <20210423210535.98130393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e8307f4bfc6e04cd601fea78129302ce02ffef8
Commit:        5e8307f4bfc6e04cd601fea78129302ce02ffef8
Parent:        66dd481f46099dd118136dacfad0e815e781605a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 14:44:57 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:54:41 2021 +0200

lvmcache: fix memory leak

With commit 0b18c25d934564015402de33e15a267045ed1b8c there
was introduced  'zalloc()' for allocation of outdates pvs,
but no matching  'free()' is present.
Switch to use cmd mempool instead of adding free() code into
several places.
---
 WHATS_NEW            | 1 +
 lib/cache/lvmcache.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a51e4a05f..7917c2690 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.12 - 
 ===================================
+  Fix memleak when generating list of outdated pvs.
   Better hyphenation usage in man pages.
   Replace use of deprecated security_context_t with char*.
   Configure supports AIO_LIBS and AIO_CFLAGS.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d4acec509..017134d7d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2818,7 +2818,7 @@ void lvmcache_get_outdated_devs(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(info, &vginfo->outdated_infos) {
-		if (!(devl = zalloc(sizeof(*devl))))
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
 			return;
 		devl->dev = info->dev;
 		dm_list_add(devs, &devl->list);


