From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:03 +0000 (UTC)
Subject: master - pool: better error message
Message-ID: <20141024144003.7E5EB60E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a98ea95c4da5afffbacd32c519734e7daef98ea9
Commit:        a98ea95c4da5afffbacd32c519734e7daef98ea9
Parent:        a2244c37764f8481fedd7d4b5f286665e9d46af2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 15:02:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

pool: better error message

---
 lib/metadata/pool_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 011d9c0..2fbadea 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -371,8 +371,8 @@ int update_pool_params(const struct segment_type *segtype,
 			return_0;
 
 	if ((uint64_t) *chunk_size > (uint64_t) data_extents * vg->extent_size) {
-		log_error("Chunk size %s is bigger then pool data size.",
-			  display_size(vg->cmd, *chunk_size));
+		log_error("Size of %s data volume cannot be smaller then chunk size %s.",
+			  segtype->name, display_size(vg->cmd, *chunk_size));
 		return 0;
 	}
 
@@ -569,6 +569,7 @@ static struct logical_volume *_alloc_pool_metadata_spare(struct volume_group *vg
 		return_0;
 
 	/* FIXME: Maybe using silent mode ? */
+	log_verbose("Preparing pool metadata spare volume for Volume group %s.", vg->name);
 	if (!(lv = lv_create_single(vg, &lp)))
 		return_0;
 
@@ -656,6 +657,7 @@ int vg_set_pool_metadata_spare(struct logical_volume *lv)
 		return 0;
 	}
 
+	log_verbose("Renaming %s as pool metadata spare volume %s.", lv->name, new_name);
 	if (!lv_rename_update(vg->cmd, lv, new_name, 0))
 		return_0;
 


