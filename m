From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Jan 2022 16:01:48 +0000 (GMT)
Subject: main - lvmcache: remove lvmcache_update_vg_from_write
Message-ID: <20220113160148.A80EB3951E5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb798ee1c102aadde93965a894c5aa59d4e76e4a
Commit:        cb798ee1c102aadde93965a894c5aa59d4e76e4a
Parent:        5e428d22d9647a294eba65852078947df5ade48f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 12 16:46:26 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 13 10:01:16 2022 -0600

lvmcache: remove lvmcache_update_vg_from_write

After a vg_write, this function was used to attempt to
make lvmcache data match the new state written to disk.
It was not updated correctly in a many or most cases,
and the resulting lvmcache is not actually used after
vg_write, making the update unnecessary.
---
 lib/cache/lvmcache.c    | 44 --------------------------------------------
 lib/cache/lvmcache.h    |  1 -
 lib/metadata/metadata.c |  7 -------
 3 files changed, 52 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c5359f3c5..6569f983d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2239,50 +2239,6 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
 	return 1;
 }
 
-/*
- * FIXME: quit trying to mirror changes that a command is making into lvmcache.
- *
- * First, it's complicated and hard to ensure it's done correctly in every case
- * (it would be much easier and safer to just toss out what's in lvmcache and
- * reread the info to recreate it from scratch instead of trying to make sure
- * every possible discrete state change is correct.)
- *
- * Second, it's unnecessary if commands just use the vg they are modifying
- * rather than also trying to get info from lvmcache.  The lvmcache state
- * should be populated by label_scan, used to perform vg_read's, and then
- * ignored (or dropped so it can't be used).
- *
- * lvmcache info is already used very little after a command begins its
- * operation.  The code that's supposed to keep the lvmcache in sync with
- * changes being made to disk could be half wrong and we wouldn't know it.
- * That creates a landmine for someone who might try to use a bit of it that
- * isn't being updated correctly.
- */
-
-int lvmcache_update_vg_from_write(struct volume_group *vg)
-{
-	char vgid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
-	struct pv_list *pvl;
-	struct lvmcache_info *info;
-	struct lvmcache_vgsummary vgsummary = {
-		.vgname = vg->name,
-		.vgstatus = vg->status,
-		.system_id = vg->system_id,
-		.lock_type = vg->lock_type
-	};
-
-	memcpy(vgid, &vg->id, ID_LEN);
-	memcpy(vgsummary.vgid, vgid, ID_LEN);
-
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if ((info = lvmcache_info_from_pv_id(&pvl->pv->id, pvl->pv->dev, 0)) &&
-		    !lvmcache_update_vgname_and_id(vg->cmd, info, &vgsummary))
-			return_0;
-	}
-
-	return 1;
-}
-
 /*
  * The lvmcache representation of a VG after label_scan can be incorrect
  * because the label_scan does not use the full VG metadata to construct
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4c4903136..934246274 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -84,7 +84,6 @@ void lvmcache_del_dev(struct device *dev);
 int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info *info,
 				  struct lvmcache_vgsummary *vgsummary);
 int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted);
-int lvmcache_update_vg_from_write(struct volume_group *vg);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
 void lvmcache_unlock_vgname(const char *vgname);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f01a0bea6..7e5605820 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3102,7 +3102,6 @@ static int _vg_commit_mdas(struct volume_group *vg)
 	DM_LIST_INIT(ignored);
 	int failed = 0;
 	int good = 0;
-	int cache_updated = 0;
 
 	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
 	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_in_use)
@@ -3123,12 +3122,6 @@ static int _vg_commit_mdas(struct volume_group *vg)
 			failed = 1;
 		} else
 			good++;
-
-		/* Update cache first time we succeed */
-		if (!failed && !cache_updated) {
-			lvmcache_update_vg_from_write(vg);
-			cache_updated = 1;
-		}
 	}
 	if (good)
 		return 1;


