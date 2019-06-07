From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:32 -0400
Subject: master - fix vg_commit return value
Message-ID: <201906072108.x57L8WaF005277@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=027e0e92e6edcde98fd951286c21a29f22f3ec20
Commit:        027e0e92e6edcde98fd951286c21a29f22f3ec20
Parent:        86d831b9165d71769cd0fc05b52bc7469760e2f0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 14:02:24 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

fix vg_commit return value

The existing comment was desribing the correct behavior,
but the code didn't match.  The commit is successful if
one mda was committed.  Making it depend on the result of
the internal lvmcache update was wrong.
---
 lib/metadata/metadata.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 65da7e1..49c1e74 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3072,6 +3072,7 @@ static int _vg_commit_mdas(struct volume_group *vg)
 	struct metadata_area *mda, *tmda;
 	struct dm_list ignored;
 	int failed = 0;
+	int good = 0;
 	int cache_updated = 0;
 
 	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
@@ -3092,27 +3093,31 @@ static int _vg_commit_mdas(struct volume_group *vg)
 		    !mda->ops->vg_commit(vg->fid, vg, mda)) {
 			stack;
 			failed = 1;
-		}
+		} else
+			good++;
+
 		/* Update cache first time we succeed */
 		if (!failed && !cache_updated) {
 			lvmcache_update_vg(vg, 0);
 			cache_updated = 1;
 		}
 	}
-	return cache_updated;
+	if (good)
+		return 1;
+	return 0;
 }
 
 /* Commit pending changes */
 int vg_commit(struct volume_group *vg)
 {
-	int cache_updated = 0;
 	struct pv_list *pvl;
+	int ret;
 
-	cache_updated = _vg_commit_mdas(vg);
+	ret = _vg_commit_mdas(vg);
 
 	set_vg_notify(vg->cmd);
 
-	if (cache_updated) {
+	if (ret) {
 		/*
 		 * We need to clear old_name after a successful commit.
 		 * The volume_group structure could be reused later.
@@ -3126,7 +3131,7 @@ int vg_commit(struct volume_group *vg)
 	}
 
 	/* If at least one mda commit succeeded, it was committed */
-	return cache_updated;
+	return ret;
 }
 
 /* Don't commit any pending changes */


