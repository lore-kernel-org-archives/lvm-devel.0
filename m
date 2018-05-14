From: David Teigland <teigland@sourceware.org>
Date: Mon, 14 May 2018 14:47:16 -0400
Subject: master - lvmcache: fix loop freeing infos
Message-ID: <201805141847.w4EIlG9t009792@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=11ceb77867560e0b804df5ec3162e9cbdc9ed321
Commit:        11ceb77867560e0b804df5ec3162e9cbdc9ed321
Parent:        517d6cc418da0ba08a971b6d537cdfada7a5b1cb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 14 13:45:55 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 14 13:45:55 2018 -0500

lvmcache: fix loop freeing infos

valgrind was concerned about loop through vginfo->infos,
so grab info from dev.
---
 lib/cache/lvmcache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 12c1c99..9912995 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1310,7 +1310,7 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 	struct dm_list devs;
 	struct device_list *devl, *devl2;
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info, *info2;
+	struct lvmcache_info *info;
 
 	if (lvmetad_used())
 		return 1;
@@ -1339,9 +1339,9 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 		dm_list_add(&devs, &devl->list);
 	}
 
-	/* Deleting the last info will delete vginfo. */
-	dm_list_iterate_items_safe(info, info2, &vginfo->infos)
-		lvmcache_del(info);
+	/* Delete info for each dev, deleting the last info will delete vginfo. */
+	dm_list_iterate_items(devl, &devs)
+		lvmcache_del_dev(devl->dev);
 
 	/* Dropping the last info struct is supposed to drop vginfo. */
 	if ((vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))


