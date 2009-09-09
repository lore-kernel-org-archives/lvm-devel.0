From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 9 Sep 2009 18:06:07 -0400
Subject: Re: Snapshot merging
In-Reply-To: <Pine.LNX.4.64.0909091318340.21052@hs20-bc2-1.build.redhat.com>
References: <4A97A035.9010604@redhat.com>
	<Pine.LNX.4.64.0908311740160.16318@hs20-bc2-1.build.redhat.com>
	<20090831221149.GB15126@redhat.com>
	<Pine.LNX.4.64.0909091142190.2960@hs20-bc2-1.build.redhat.com>
	<20090909155642.GB15981@redhat.com>
	<20090909161247.GA16156@redhat.com>
	<Pine.LNX.4.64.0909091318340.21052@hs20-bc2-1.build.redhat.com>
Message-ID: <20090909220607.GA26555@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Sep 09 2009 at  1:23pm -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Wed, 9 Sep 2009, Mike Snitzer wrote:
> 
> > On Wed, Sep 09 2009 at 11:56am -0400,
> > Mike Snitzer <snitzer@redhat.com> wrote:
> > 
> > > On Wed, Sep 09 2009 at 11:47am -0400,
> > > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > 
> > > > Hi
> > > > 
> > > > I found one bug in the userspace code --- start merging, then from the 
> > > > other console deactivate the origin volume with lvchange -an, then wait 
> > > > next 15 seconds for the next poll interval:
> > > > 
> > > > the poll process will think that the merging finished, removing the 
> > > > snapshot, leaving partially merged origin and causing data corruption:
> > > > 
> > > > [slunicko:~]# lvconvert -M vg1/lv2_snap1
> > > >   Merging of volume lv2_snap1 started.
> > > >   lv2: Merged: 13.1%
> > > > ( .... deactivate the volume from the other console ....)
> > > >   lv2: Merged: -1.0%
> > > >   Merge into logical volume lv2 finished.
> > > >   Logical volume "snapshot4" successfully removed
> > > > 
> > > > Maybe this bug was in my code too, I don't remember.
> > > 
> > > Likely, considering I merely ported your LVM2 patches to the latest
> > > version.  That said, I could've introduced this issue by missing
> > > something in the port.  Regardless, I'll have a look at preventing the
> > > origin LV from being deactivated during a merge.
> > 
> > Or more correctly: gracefully halt the merge and deactivate merging
> > snapshot along with the origin.  Then on activation the merge should
> > just resume (in the background).
> > 
> > Mike
> 
> I'd patch _poll_merge_progress to return zero (instead of 
> PROGRESS_FINISHED) if querying the lv failed (lv_snapshot_percent returned 
> zero) --- that should terminate the polling process without updating 
> anything.
> 
> You can try it and test it.

[cc'ing lvm-devel too]

Thanks for the pointer; that was part of the fix.

But it wasn't sufficient because lib/activate/dev_manager.c:_percent_run()
was not properly returning TARGET_STATUS_ERROR.

I've updated the 2 relevant patches with the following inter-diffs;
these changes fix things for me.  I've uploaded the updated patches as
usual, see:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.52-cvs/

updated lvm-report-state-in-return-value-of-target_percent.patch contains:

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index aa75e5b..a55bf2f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -493,7 +493,8 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
 }
 
 /*
- * Returns 1 if percent set, else 0 on failure.
+ * Returns TARGET_STATUS_PROCESSING or TARGET_STATUS_FINISHED if percent set;
+ * else TARGET_STATUS_ERROR or TARGET_STATUS_INVALIDATED on failure.
  */
 int lv_snapshot_percent(const struct logical_volume *lv, float *percent)
 {
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6495b8c..d701c71 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -333,7 +333,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			struct logical_volume *lv, float *percent,
 			uint32_t *event_nr)
 {
-	int r = TARGET_STATUS_FINISHED;
+	int r = TARGET_STATUS_ERROR;
 	struct dm_task *dmt;
 	struct dm_info info;
 	void *next = NULL;
@@ -364,6 +364,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	if (event_nr)
 		*event_nr = info.event_nr;
 
+	r = TARGET_STATUS_FINISHED;
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length, &type,
 					  &params);
@@ -396,6 +397,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	} while (next);
 
 	if (lv && (segh = dm_list_next(&lv->segments, segh))) {
+		r = TARGET_STATUS_ERROR;
 		log_error("Number of segments in active LV %s does not "
 			  "match metadata", lv->name);
 		goto out;

updated lvm-merge-background-poll.patch contains:

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d5afca4..3b46e11 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -360,15 +360,18 @@ static int _poll_merge_progress(struct cmd_context *cmd,
 {
 	int r;
 	float percent;
-	if (!(r = lv_snapshot_percent(lv, &percent))) {
-		log_error("Failed to query for merging percentage of lv %s.", lv->name);
+
+	r = lv_snapshot_percent(lv, &percent);
+	if (r == TARGET_STATUS_ERROR) {
+		log_error("Failed query for merging percentage of lv %s.", lv->name);
 		/* returning zero terminates the polling process */
 		return 0;
 	}
-	if (r == TARGET_STATUS_INVALIDATED) {
+	else if (r == TARGET_STATUS_INVALIDATED) {
 		log_print("%s: Snapshot invalidated, aborting merging", lv->name);
 		return PROGRESS_FINISHED;
 	}
+
 	if (parms->progress_display)
 		log_print("%s: %s: %.1f%%", lv->name, parms->progress_title, percent);
 	else


