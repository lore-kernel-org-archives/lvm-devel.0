From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:48 +0000 (UTC)
Subject: master - file-locking: skip locking of VG_SYNC_NAMES
Message-ID: <20141024143948.D135760E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab940456931ea5a5a6f29f63d1b27057df3fdf75
Commit:        ab940456931ea5a5a6f29f63d1b27057df3fdf75
Parent:        9351dca86393f862a6b2c270d5869407a4614d8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 14:47:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:30 2014 +0200

file-locking: skip locking of VG_SYNC_NAMES

VG_SYNC_NAMES is internal name with different meaning,
there is no point to search it in cache.
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 38a4d1b..4d2a6d2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Skip trying to file lock virtual internal vg name.
   Fix selection on {vg,lv}_permissions fields to properly match selection criteria.
   Fix lv_permissions reporting to display read-only{-override} instead of blank.
   Fix liblvm2cmd and lvm shell to respect quotes around args in cmd line string.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 5fd0ed3..0595752 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -60,12 +60,11 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			return_0;
 		break;
 	case LCK_VG:
-		/* Skip cache refresh for VG_GLOBAL - the caller handles it */
-		if (strcmp(resource, VG_GLOBAL))
-			lvmcache_drop_metadata(resource, 0);
-
-		if (!strcmp(resource, VG_SYNC_NAMES))
+		if (!strcmp(resource, VG_SYNC_NAMES)) {
 			fs_unlock();
+		} else if (strcmp(resource, VG_GLOBAL))
+			/* Skip cache refresh for VG_GLOBAL - the caller handles it */
+			lvmcache_drop_metadata(resource, 0);
 
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)


