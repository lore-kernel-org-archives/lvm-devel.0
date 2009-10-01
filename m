From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 1 Oct 2009 17:31:08 -0400
Subject: Re: [PATCH 1/2] Avoid depending on comparison of floating-point values.
In-Reply-To: <20091001004200.GY5351@agk-dp.fab.redhat.com>
References: <1254236202-30381-1-git-send-email-snitzer@redhat.com>
	<1254236202-30381-2-git-send-email-snitzer@redhat.com>
	<20091001004200.GY5351@agk-dp.fab.redhat.com>
Message-ID: <20091001213108.GA5702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 30 2009 at  8:42pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Tue, Sep 29, 2009 at 10:56:41AM -0400, Mike Snitzer wrote:
> > TARGET_STATUS_ERROR --- error occured
> > TARGET_STATUS_INVALIDATED --- the snapshot is invalidated (there may still exist
> > 	100% filled snapshot that is not invalidated)
> > TARGET_STATUS_PROCESSING --- mirror is resynchronizing, snapshot is neither
> > 	empty nor invalidated.
> > TARGET_STATUS_FINISHED --- finished. For mirrors, it is returned when the mirror
> > 	resynchronization finished. For snapshots, it is returned when the
> > 	snapshot contains no exceptions (merging finished).
> 
> I've done this as a new percent_range_t enum, reporting whether the
> percentage is 0, 100, or between those two and leaving it to the caller
> to interpret what the percentage means (e.g. finished) in each
> particular context.  I've not checked all the code paths so more
> tweaking could be required.
> 
> In the snapshot case, I'm expecting we can define PERCENT_0 to ignore
> the header stored in the cow.

This works but I need to look at further abstracting the check for
whether the exception store is empty (PERCENT_0) based on type.  But we
currently only support persistent in LVM...

---
 lib/activate/dev_manager.c |    7 +++++--
 lib/activate/dev_manager.h |    2 +-
 lib/snapshot/snapshot.c    |   10 ++++++++--
 3 files changed, 14 insertions(+), 5 deletions(-)

Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -393,6 +393,9 @@ static int _percent_run(struct dev_manag
 				goto out;
 			}
 			seg = dm_list_item(segh, struct lv_segment);
+			/* if snapshot, target_percent needs the cow segment */
+			if (lv_is_cow(lv))
+				seg = find_cow(lv);
 		}
 
 		if (!type || !params || strcmp(type, target_type))
@@ -513,7 +516,7 @@ void dev_manager_exit(void)
 }
 
 int dev_manager_snapshot_percent(struct dev_manager *dm,
-				 const struct logical_volume *lv,
+				 struct logical_volume *lv,
 				 float *percent, percent_range_t *percent_range)
 {
 	char *name;
@@ -532,7 +535,7 @@ int dev_manager_snapshot_percent(struct 
 	 * Try and get some info on this device.
 	 */
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+	if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
 		       percent_range, NULL)))
 		return_0;
 
Index: lvm2/lib/snapshot/snapshot.c
===================================================================
--- lvm2.orig/lib/snapshot/snapshot.c
+++ lvm2/lib/snapshot/snapshot.c
@@ -91,7 +91,7 @@ static int _snap_target_percent(void **t
 				percent_range_t *percent_range,
 				struct dm_pool *mem __attribute((unused)),
 				struct cmd_context *cmd __attribute((unused)),
-				struct lv_segment *seg __attribute((unused)),
+				struct lv_segment *seg,
 				char *params, uint64_t *total_numerator,
 				uint64_t *total_denominator)
 {
@@ -101,7 +101,13 @@ static int _snap_target_percent(void **t
 		   &numerator, &denominator) == 2) {
 		*total_numerator += numerator;
 		*total_denominator += denominator;
-		if (!numerator)
+		/*
+		 * DM doesn't report 0 if the persistent exception
+		 * store is empty; detect empty based on store type
+		 * - FIXME: need exception store-specific helper to
+		 *   test if store is empty
+		 */
+		if (numerator == 2 * seg->chunk_size)
 			*percent_range = PERCENT_0;
 		else if (numerator == denominator)
 			*percent_range = PERCENT_100;
Index: lvm2/lib/activate/dev_manager.h
===================================================================
--- lvm2.orig/lib/activate/dev_manager.h
+++ lvm2/lib/activate/dev_manager.h
@@ -45,7 +45,7 @@ int dev_manager_info(struct dm_pool *mem
 		     int mknodes, int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
-				 const struct logical_volume *lv,
+				 struct logical_volume *lv,
 				 float *percent,
 				 percent_range_t *percent_range);
 int dev_manager_mirror_percent(struct dev_manager *dm,


