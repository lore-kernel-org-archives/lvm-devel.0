From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 10 Feb 2010 08:40:35 -0500
Subject: a bug in snapshots
In-Reply-To: <20100210040125.GA24479@redhat.com>
References: <Pine.LNX.4.64.1002091904560.14493@hs20-bc2-1.build.redhat.com>
	<20100210003902.GA7441@redhat.com>
	<Pine.LNX.4.64.1002092053560.3180@hs20-bc2-1.build.redhat.com>
	<20100210040125.GA24479@redhat.com>
Message-ID: <20100210134035.GA8201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 09 2010 at 11:01pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Tue, Feb 09 2010 at  8:57pm -0500,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > 
> > 
> > On Tue, 9 Feb 2010, Mike Snitzer wrote:
> > 
> > > On Tue, Feb 09 2010 at  7:07pm -0500,
> > > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > 
> > > > Hi
> > > > 
> > > > Try to make a snapshot that is so big that it spans more than one physical 
> > > > volume. Then, type "lvs" command. You get these errors:
> > > > 
> > > > [slunicko:/usr/src/LVM2.2.02.60]# lvs
> > > >   Number of segments in active LV lvol1 does not match metadata
> > > >   Number of segments in active LV lvol1 does not match metadata
> > > >   Number of segments in active LV lvol1 does not match metadata
> > > >   Number of segments in active LV lvol1 does not match metadata
> > > >   LV    VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
> > > >   lvol0 vg1  owi-a- 16.00m
> > > >   lvol1 vg1  Swi-I- 60.00m lvol0  100.00
> > > >   m     vg1  -wi-a- 64.00m
> > > > 
> > > > This bug was introduced in LVM2.2.02.59 with this change:
> > > > 
> > > > --- ./LVM2.2.02.58/lib/activate/dev_manager.c   2010-01-13 
> > > > 02:55:44.000000000 +0100
> > > > +++ ./LVM2.2.02.59/lib/activate/dev_manager.c   2010-01-15 
> > > > 23:58:25.000000000 +0100
> > > > @@ -584,7 +593,7 @@ int dev_manager_snapshot_percent(struct
> > > >          * Try and get some info on this device.
> > > >          */
> > > >         log_debug("Getting device status percentage for %s", name);
> > > > -       if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
> > > > +       if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
> > > >                        percent_range, NULL)))
> > > >                 return_0;
> > > > 
> > > 
> > > That change was part of this commit:
> > > http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=13713bc147
> > > 
> > > I'm not seeing how this commit has any functional change for anything
> > > other than snapshot-merge related snapshots.
> > > 
> > > All I did was pass lv into _percent() (and then _percent_run()) so that
> > > I could inspect it to know if lv_is_merging_origin().
> > > 
> > > The vg1/lvol1's flags indicate the snapshot is set to merge and it is
> > > also invalid.  Can you detail your testcase a bit more please?
> > > 
> > > Are you certain there isn't some other reason your test case is failing?
> > > 
> > > Mike
> > 
> > The problem is that when you pass non-NULL lv to _percent_run(), it tries 
> > to verify that the number of segments in that lv is equal to the number of 
> > targets. And it isn't --- the lv can have more than one segment but there 
> > is just one "snapshot" target. That's why it fails.
> 
> I see.  I was too focused on the commit; didn't look at the rest of
> _percent_run(), etc.
> 
> > What to do with it? Drop this verification? Or pass NULL as lv there, like 
> > before?
> 
> Well the reality is we really shouldn't be passing a snapshot-origin
> into _percent_run() to begin with.  I made it so that we filter it out
> very late, in _percent_run, in cases where snapshot-merge completion
> polling gets started even though the snapshot was not allowed to start
> merging (as is possible if a snapshot or snapshot-origin is still open
> when a 'lvchange --refresh origin' occurs).
> 
> So one thing we could do is move the lv_is_merging_origin() much earlier
> and revert to passing a NULL lv to _percent().
> 
> Another option is to audit that segment count check in _percent_run()
> and possibly only make that check for cases where it really matters.

Here is what I came up with.  Justification for this approach is
explained in the dev_manager_snapshot_percent() comment below.

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6fbc392..ab4f16c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -423,7 +423,7 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *target_type, int wait,
 			const struct logical_volume *lv, float *percent,
 			percent_range_t *overall_percent_range,
-			uint32_t *event_nr)
+			uint32_t *event_nr, int fail_if_percent_unsupported)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -516,10 +516,8 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			/* above ->target_percent() was not executed! */
 			/* FIXME why return PERCENT_100 et. al. in this case? */
 			*overall_percent_range = PERCENT_100;
-			if (lv && lv_is_merging_origin(lv)) {
-				/* must fail in snapshot-merge case */
+			if (fail_if_percent_unsupported)
 				goto_out;
-			}
 		} else
 			*overall_percent_range = combined_percent_range;
 	}
@@ -535,20 +533,24 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const char *target_type, int wait,
 		    const struct logical_volume *lv, float *percent,
-		    percent_range_t *overall_percent_range, uint32_t *event_nr)
+		    percent_range_t *overall_percent_range, uint32_t *event_nr,
+		    int fail_if_percent_unsupported)
 {
 	if (dlid && *dlid) {
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr))
+				 overall_percent_range, event_nr,
+				 fail_if_percent_unsupported))
 			return 1;
 		else if (_percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				      target_type, wait, lv, percent,
-				      overall_percent_range, event_nr))
+				      overall_percent_range, event_nr,
+				      fail_if_percent_unsupported))
 			return 1;
 	}
 
 	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 overall_percent_range, event_nr))
+				 overall_percent_range, event_nr,
+				 fail_if_percent_unsupported))
 		return 1;
 
 	return 0;
@@ -607,6 +609,21 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 {
 	char *name;
 	const char *dlid;
+	int fail_if_percent_unsupported = 0;
+
+	if (lv_is_merging_origin(lv)) {
+		/*
+		 * Passing unsupported LV types to _percent will lead to a
+		 * default successful return with percent_range as PERCENT_100.
+		 * - For a merging origin, this will result in a polldaemon
+		 *   that runs infinitely (because completion is PERCENT_0)
+		 * - We unfortunately don't yet _know_ if a snapshot-merge
+		 *   target is active (activation is deferred if dev is open);
+		 *   so we can't short-circuit origin devices based purely on
+		 *   existing LVM LV attributes.
+		 */
+		fail_if_percent_unsupported = 1;
+	}
 
 	/*
 	 * Build a name for the top layer.
@@ -621,8 +638,8 @@ int dev_manager_snapshot_percent(struct dev_manager *dm,
 	 * Try and get some info on this device.
 	 */
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "snapshot", 0, lv, percent,
-		       percent_range, NULL)))
+	if (!(_percent(dm, name, dlid, "snapshot", 0, NULL, percent,
+		       percent_range, NULL, fail_if_percent_unsupported)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
@@ -657,7 +674,7 @@ int dev_manager_mirror_percent(struct dev_manager *dm,
 
 	log_debug("Getting device mirror status percentage for %s", name);
 	if (!(_percent(dm, name, dlid, "mirror", wait, lv, percent,
-		       percent_range, event_nr)))
+		       percent_range, event_nr, 0)))
 		return_0;
 
 	return 1;


