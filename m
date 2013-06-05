From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:04 +0000 (UTC)
Subject: dev-mornfall-lvmcache - snapshot: use dm_get_status_snapshot()
Message-ID: <20130605120404.55A2C60F18@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06e8ff29ff59a1893312f5b2d5e818c8c62ee7b1
Commit:        06e8ff29ff59a1893312f5b2d5e818c8c62ee7b1
Parent:        cb587fd10034fa65ebba177022aba10e7a64aacd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 26 17:04:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:32:02 2013 +0200

snapshot: use dm_get_status_snapshot()

Replace code with libdm call to dm_get_status_snapshot().
---
 WHATS_NEW               |    1 +
 lib/snapshot/snapshot.c |   36 +++++++++++++++---------------------
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e63e000..734e86c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Use libdm dm_get_status_snapshot() to parse snapshot status.
   Add detection of mounted fs also for vgchange deactivation.
   Replace 'lv_is_active' with more correct/specific variants (e.g. *_locally).
   Refuse to init a snapshot merge in lvconvert if there's no kernel support.
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 2bab9d2..453d96a 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -117,32 +117,26 @@ static int _snap_target_percent(void **target_state __attribute__((unused)),
 				char *params, uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
-	uint64_t total_sectors, sectors_allocated, metadata_sectors;
-	int r;
-
-	/*
-	 * snapshot target's percent format:
-	 * <= 1.7.0: <sectors_allocated>/<total_sectors>
-	 * >= 1.8.0: <sectors_allocated>/<total_sectors> <metadata_sectors>
-	 */
-	r = sscanf(params, "%" PRIu64 "/%" PRIu64 " %" PRIu64,
-		   &sectors_allocated, &total_sectors, &metadata_sectors);
-	if (r == 2 || r == 3) {
-		*total_numerator += sectors_allocated;
-		*total_denominator += total_sectors;
-		if (r == 3 && sectors_allocated == metadata_sectors)
+	struct dm_status_snapshot *s;
+
+	if (!dm_get_status_snapshot(mem, params, &s))
+		return_0;
+
+	if (s->invalid)
+		*percent = PERCENT_INVALID;
+	else if (s->merge_failed)
+		*percent = PERCENT_MERGE_FAILED;
+	else {
+		*total_numerator += s->used_sectors;
+		*total_denominator += s->total_sectors;
+		if (s->has_metadata_sectors &&
+		    s->used_sectors == s->metadata_sectors)
 			*percent = PERCENT_0;
-		else if (sectors_allocated == total_sectors)
+		else if (s->used_sectors == s->total_sectors)
 			*percent = PERCENT_100;
 		else
 			*percent = make_percent(*total_numerator, *total_denominator);
 	}
-	else if (!strcmp(params, "Invalid"))
-		*percent = PERCENT_INVALID;
-	else if (!strcmp(params, "Merge failed"))
-		*percent = PERCENT_MERGE_FAILED;
-	else
-		return 0;
 
 	return 1;
 }


