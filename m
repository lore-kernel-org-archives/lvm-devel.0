From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:02 +0000 (UTC)
Subject: dev-mornfall-lvmcache - libdm: free mem pool on err path
Message-ID: <20130605120402.3CE9760F18@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb587fd10034fa65ebba177022aba10e7a64aacd
Commit:        cb587fd10034fa65ebba177022aba10e7a64aacd
Parent:        4707ac7200ba559ad080e4349f660c0a7559610c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 26 17:00:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:30:55 2013 +0200

libdm: free mem pool on err path

Since we use get_status also in dmeventd, which may use one pool
for a single device, in case it would be repeatedly returning error,
it may not be freeing the pool and would cause slow but steady growth.
To stay safe in the error path release any allocated memory.
---
 libdm/libdm-deptree.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 56522f1..2201b30 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2955,10 +2955,10 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		return_0;
 
 	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
-		return_0; /* memory is freed went pool is destroyed */
+		goto_bad; /* memory is freed went pool is destroyed */
 
 	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
-		return_0;
+		goto_bad;
 
 	if (sscanf(params, "%s %d %s %" PRIu64 "/%" PRIu64,
 		   s->raid_type,
@@ -2967,7 +2967,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		   &s->insync_regions,
 		   &s->total_regions) != 5) {
 		log_error("Failed to parse raid params: %s", params);
-		return 0;
+		goto bad;
 	}
 
 	*status = s;
@@ -2986,19 +2986,23 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	pp = p;
 	if (!(p = strchr(p, ' '))) {
 		log_error(INTERNAL_ERROR "Bad RAID status received.");
-		return 0;
+		goto bad;
 	}
 	p++;
 
 	if (!(s->sync_action = dm_pool_zalloc(mem, p - pp)))
-		return_0;
+		goto_bad;
 
 	if (sscanf(pp, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2) {
 		log_error("Failed to parse raid params: %s", params);
-		return 0;
+		goto bad;
 	}
 
 	return 1;
+bad:
+	dm_pool_free(mem, s);
+
+	return 0;
 }
 
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
@@ -3428,6 +3432,7 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 		   &s->total_metadata_blocks,
 		   &s->used_data_blocks,
 		   &s->total_data_blocks, &pos) < 5) {
+		dm_pool_free(mem, s);
 		log_error("Failed to parse thin pool params: %s.", params);
 		return 0;
 	}
@@ -3468,6 +3473,7 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 	} else if (sscanf(params, "%" PRIu64 " %" PRIu64,
 		   &s->mapped_sectors,
 		   &s->highest_mapped_sector) != 2) {
+		dm_pool_free(mem, s);
 		log_error("Failed to parse thin params: %s.", params);
 		return 0;
 	}


