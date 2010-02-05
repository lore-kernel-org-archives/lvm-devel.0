From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Feb 2010 22:44:39 -0000
Subject: LVM2 man/lvconvert.8.in test/t-snapshot-merge. ...
Message-ID: <20100205224439.12015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-05 22:44:38

Modified files:
	man            : lvconvert.8.in 
	test           : t-snapshot-merge.sh 
	tools          : lvconvert.c 

Log message:
	lvconvert --merge @tag support
	
	Switch lvconvert's --merge code over to using process_each_lv().  Doing
	so adds support for a single 'lvconvert --merge' to start merging
	multiple LVs (which includes @tag expansion).
	
	Add 'lvconvert --merge @tag' testing to test/t-snapshot-merge.sh
	
	Adjust man/lvconvert.8.in to reflect these expanded capabilities.
	
	The lvconvert.c implementation requires rereading the VG each iteration
	of process_each_lv().  Otherwise a stale VG instance associated with
	the LV passed to lvconvert_single_merge() would result in stale VG
	metadata being written back out to disk.  This overwrote new metadata
	that was written when a previous snapshot LV finished merging (via
	lvconvert_poll).  This is only an issue when merging multiple LVs that
	share the same VG (a single VG is typical for most LVM configurations on
	system disks).
	
	In the end this new support is very useful for performing a "system
	rollback" that requires multiple snapshot LVs be merged to their
	respective origin LV.
	
	The yum-utils 'fs-snapshot' plugin tags all snapshot LVs that it creates
	with a common 'snapshot_tag' that is unique to the yum transaction.
	Rolling back a yum transaction, that created LVM snapshots with the tag
	'yum_20100129133223', is as simple as:
	lvconvert --merge @yum_20100129133223
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/man/lvconvert.8.in	2010/01/13 01:55:05	1.13
+++ LVM2/man/lvconvert.8.in	2010/02/05 22:44:37	1.14
@@ -39,7 +39,7 @@
 [\-h|\-?|\-\-help]
 [\-v|\-\-verbose]
 [\-\-version]
-SnapshotLogicalVolume[Path]
+SnapshotLogicalVolume[Path]...
 .br
 
 .br
@@ -141,7 +141,9 @@
 When merging starts, the resulting logical volume will have the origin's name,
 minor number and UUID.  While the merge is in progress, reads or writes to the
 origin appear as they were directed to the snapshot being merged.  When the
-merge finishes, the merged snapshot is removed.
+merge finishes, the merged snapshot is removed.  Multiple snapshots may
+be specified on the commandline or a @tag may be used to specify
+multiple snapshots be merged to their respective origin.
 .br
 
 
@@ -199,6 +201,14 @@
 .br
 merges "vg00/lvol1_snap" into its origin.
 
+.br
+"lvconvert --merge @some_tag"
+.br
+If vg00/lvol1, vg00/lvol2, and vg00/lvol3 are all tagged with "some_tag"
+each snapshot logical volume will be merged serially, e.g.: vg00/lvol1,
+then vg00/lvol2, then vg00/lvol3.  If --background were used it would start
+all snapshot logical volume merges in parallel.
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/test/t-snapshot-merge.sh	2010/01/19 22:55:00	1.1
+++ LVM2/test/t-snapshot-merge.sh	2010/02/05 22:44:38	1.2
@@ -77,6 +77,17 @@
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
+# test merging multiple snapshots that share the same tag
+setup_merge $vg $lv1
+setup_merge $vg $lv2
+lvs -a
+lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv1)
+lvchange --addtag this_is_a_test $vg/$(snap_lv_name_ $lv2)
+lvconvert --merge @this_is_a_test
+lvs | not grep $(snap_lv_name_ $lv1)
+lvs | not grep $(snap_lv_name_ $lv2)
+lvremove -f $vg/$lv1
+lvremove -f $vg/$lv2
 
 # FIXME following tests would need to poll merge progress, via periodic lvs?
 # Background processes don't lend themselves to lvm testsuite...
--- LVM2/tools/lvconvert.c	2010/02/05 22:40:49	1.117
+++ LVM2/tools/lvconvert.c	2010/02/05 22:44:38	1.118
@@ -55,7 +55,10 @@
 	char *ptr;
 	const char *vg_name = NULL;
 
-	if (lp->snapshot && !lp->merge) {
+	if (lp->merge)
+		return 1;
+
+	if (lp->snapshot) {
 		if (!*pargc) {
 			log_error("Please specify a logical volume to act as "
 				  "the snapshot origin.");
@@ -105,7 +108,7 @@
 	if (!apply_lvname_restrictions(lp->lv_name))
 		return_0;
 
-	if (*pargc && (lp->snapshot || lp->merge)) {
+	if (*pargc && lp->snapshot) {
 		log_error("Too many arguments provided for snapshots");
 		return 0;
 	}
@@ -1222,8 +1225,8 @@
 	return r;
 }
 
-static int lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
-			    void *handle)
+static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
+			     void *handle)
 {
 	struct lvconvert_params *lp = handle;
 
@@ -1293,60 +1296,154 @@
 	return ECMD_PROCESSED;
 }
 
-int lvconvert(struct cmd_context * cmd, int argc, char **argv)
+/*
+ * FIXME move to toollib along with the rest of the drop/reacquire
+ * VG locking that is used by lvconvert_merge_single()
+ */
+static struct logical_volume *get_vg_lock_and_logical_volume(struct cmd_context *cmd,
+							     const char *vg_name,
+							     const char *lv_name)
 {
+	/*
+	 * Returns NULL if the requested LV doesn't exist;
+	 * otherwise the caller must vg_release(lv->vg)
+	 * - it is also up to the caller to unlock_vg() as needed
+	 */
 	struct volume_group *vg;
-	struct lv_list *lvl;
-	struct lvconvert_params lp;
-	int ret = ECMD_FAILED;
+	struct logical_volume* lv = NULL;
+
+	vg = _get_lvconvert_vg(cmd, vg_name, NULL);
+	if (vg_read_error(vg)) {
+		vg_release(vg);
+		log_error("ABORTING: Can't reread VG for %s", vg_name);
+		return NULL;
+	}
+
+	if (!(lv = _get_lvconvert_lv(cmd, vg, lv_name, NULL, 0))) {
+		log_error("ABORTING: Can't find LV %s in VG %s", lv_name, vg_name);
+		unlock_and_release_vg(cmd, vg, vg_name);
+		return NULL;
+	}
+
+	return lv;
+}
+
+static int poll_logical_volume(struct cmd_context *cmd, struct logical_volume *lv,
+			       int wait_completion)
+{
 	struct lvinfo info;
-	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
-	if (!_read_params(&lp, cmd, argc, argv)) {
-		stack;
-		return EINVALID_CMD_LINE;
+	if (!lv_info(cmd, lv, &info, 1, 0) || !info.exists) {
+		log_print("Conversion starts after activation.");
+		return ECMD_PROCESSED;
 	}
+	return lvconvert_poll(cmd, lv, wait_completion ? 0 : 1U);
+}
+
+static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp)
+{
+	struct volume_group *vg;
+	struct lv_list *lvl;
+	int ret = ECMD_FAILED;
+	int saved_ignore_suspended_devices = ignore_suspended_devices();
 
 	if (arg_count(cmd, repair_ARG)) {
 		init_ignore_suspended_devices(1);
 		cmd->handles_missing_pvs = 1;
 	}
 
-	log_verbose("Checking for existing volume group \"%s\"", lp.vg_name);
+	log_verbose("Checking for existing volume group \"%s\"", lp->vg_name);
 
-	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, lp->vg_name, NULL, 0);
 	if (vg_read_error(vg))
 		goto out;
 
-	if (!(lvl = find_lv_in_vg(vg, lp.lv_name))) {
+	if (!(lvl = find_lv_in_vg(vg, lp->lv_name))) {
 		log_error("Logical volume \"%s\" not found in "
-			  "volume group \"%s\"", lp.lv_name, lp.vg_name);
+			  "volume group \"%s\"", lp->lv_name, lp->vg_name);
 		goto bad;
 	}
 
-	if (lp.pv_count) {
-		if (!(lp.pvh = create_pv_list(cmd->mem, vg, lp.pv_count,
-					      lp.pvs, 0)))
+	if (lp->pv_count) {
+		if (!(lp->pvh = create_pv_list(cmd->mem, vg, lp->pv_count,
+					      lp->pvs, 0)))
 			goto_bad;
 	} else
-		lp.pvh = &vg->pvs;
-
-	lp.lv_to_poll = lvl->lv;
-	ret = lvconvert_single(cmd, lvl->lv, &lp);
+		lp->pvh = &vg->pvs;
 
+	lp->lv_to_poll = lvl->lv;
+	ret = _lvconvert_single(cmd, lvl->lv, lp);
 bad:
-	unlock_vg(cmd, lp.vg_name);
+	unlock_vg(cmd, lp->vg_name);
 
-	if (ret == ECMD_PROCESSED && lp.need_polling) {
-		if (!lv_info(cmd, lp.lv_to_poll, &info, 1, 0) || !info.exists) {
-			log_print("Conversion starts after activation");
-			goto out;
-		}
-		ret = lvconvert_poll(cmd, lp.lv_to_poll,
-				     lp.wait_completion ? 0 : 1U);
-	}
+	if (ret == ECMD_PROCESSED && lp->need_polling)
+		ret = poll_logical_volume(cmd, lp->lv_to_poll,
+					  lp->wait_completion);
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
 	vg_release(vg);
 	return ret;
 }
+
+static int lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
+				  void *handle)
+{
+	struct lvconvert_params *lp = handle;
+	const char *vg_name = NULL;
+	struct logical_volume *refreshed_lv = NULL;
+	int ret;
+
+	/*
+	 * FIXME can't trust lv's VG to be current given that caller
+	 * is process_each_lv() -- poll_logical_volume() may have
+	 * already updated the VG's metadata in an earlier iteration.
+	 * - preemptively drop the VG lock, as is needed for
+	 *   poll_logical_volume(), refresh LV (and VG in the process).
+	 */
+	vg_name = lv->vg->name;
+	unlock_vg(cmd, vg_name);
+	refreshed_lv = get_vg_lock_and_logical_volume(cmd, vg_name, lv->name);
+	if (!refreshed_lv)
+		return ECMD_FAILED;
+
+	lp->lv_to_poll = refreshed_lv;
+	ret = _lvconvert_single(cmd, refreshed_lv, lp);
+
+	if (ret == ECMD_PROCESSED && lp->need_polling) {
+		/*
+		 * Must drop VG lock, because lvconvert_poll() needs it,
+		 * then reacquire it after polling completes
+		 */
+		unlock_vg(cmd, vg_name);
+
+		ret = poll_logical_volume(cmd, lp->lv_to_poll,
+					  lp->wait_completion);
+
+		/* use LCK_VG_WRITE to match lvconvert()'s READ_FOR_UPDATE */
+		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
+			log_error("ABORTING: Can't relock VG for %s "
+				  "after polling finished", vg_name);
+			ret = ECMD_FAILED;
+		}
+	}
+
+	vg_release(refreshed_lv->vg);
+
+	return ret;
+}
+
+int lvconvert(struct cmd_context * cmd, int argc, char **argv)
+{
+	struct lvconvert_params lp;
+
+	if (!_read_params(&lp, cmd, argc, argv)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
+
+	if (lp.merge)
+		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &lp,
+				       &lvconvert_merge_single);
+
+	return lvconvert_single(cmd, &lp);
+}


