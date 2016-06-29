From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Jun 2016 21:55:52 +0000 (UTC)
Subject: master - lvconvert: rework routing of operations
Message-ID: <20160629215552.201A561134@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2282f53ac73d33311661226894ee90e72772f0db
Commit:        2282f53ac73d33311661226894ee90e72772f0db
Parent:        eac0706761e628532ffcd27f3e4d7fa559a5f818
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 28 12:24:41 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 29 16:55:27 2016 -0500

lvconvert: rework routing of operations

Add new logic to identify each unique operation and route
it to the correct function to perform it.  The functions
that perform the conversions remain unchanged.

This new code checks every allowed combination of LV type
and requested operation, and for each valid combination
calls the function that performs that conversion.

The first stage of option validation which checks for
incompatible combinations of command line options, is done
done before process_each is called.  This is unchanged.
(This new code will allow that first stage validation to
be simplified in a future commit.)

The second stage of checking options against the specific
LV type is done by this new code.  For each valid combination
of operation + LV type, the new code calls an existing
function that implements it.

With this in place, the ad hoc checks for valid combinations
of LV types and operations can be removed from the existing
code in a future commit.

(The #if 0 is used to keep the patch clean, and the
disabled code will be removed by a following patch.)
---
 test/shell/lvconvert-cache.sh  |    2 +-
 test/shell/lvconvert-mirror.sh |   21 +-
 tools/lvconvert.c              |  786 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 799 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index cab5964..58274de 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -144,7 +144,7 @@ lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 
 # unsupported yet
 fail lvconvert --repair $vg/cpool 2>&1 | tee out
-grep "not yet implemented" out
+grep "Cannot convert internal LV" out
 
 lvremove -f $vg
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 078ebad..1d4fb08 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -85,9 +85,12 @@ offset=$(( offset + 2 ))
 # update in case  mirror ever gets faster and allows parallel read
 aux delay_dev "$dev2" 0 2000 ${offset}:1
 lvcreate -aey -l5 -Zn -Wn --type mirror --regionsize 16K -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+# FIXME: add a new explicit option to define the polling behavior
+# done here with 'lvconvert vg/lv'.  That option can specify
+# that the command succeeds even if the LV doesn't need polling.
 should not lvconvert -m-1 $vg/$lv1 "$dev1"
 aux enable_dev "$dev2"
-lvconvert $vg/$lv1 # wait
+should lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
 aux wait_for_sync $vg $lv1
@@ -113,7 +116,7 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # Next convert should fail b/c we can't have 2 at once
 should not lvconvert -m+1 $vg/$lv1 "$dev5"
 aux enable_dev "$dev4"
-lvconvert $vg/$lv1 # wait
+should lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
 
 check mirror $vg $lv1 "$dev3"
@@ -156,7 +159,7 @@ lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -aey $vg/$lv1
-lvconvert $vg/$lv1 # wait
+should lvconvert $vg/$lv1 # wait
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
 lvremove -ff $vg
@@ -168,7 +171,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-lvconvert $vg/$lv1 # wait
+should lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -179,7 +182,7 @@ lvremove -ff $vg
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
-lvconvert $vg/$lv1 # wait
+should lvconvert $vg/$lv1 # wait
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -192,9 +195,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-lvconvert $vg/$lv1
+should lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-lvconvert $vg/$lv1
+should lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -207,9 +210,9 @@ LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -b $vg/$lv1 "$dev4"
 # FIXME: Extra wait here for mirror upconvert synchronization
 # otherwise we may fail her on parallel upconvert and downconvert
 # lvconvert-mirror-updown.sh tests this errornous case separately
-lvconvert $vg/$lv1
+should lvconvert $vg/$lv1
 lvconvert -m-1 $vg/$lv1 "$dev2"
-lvconvert $vg/$lv1
+should lvconvert $vg/$lv1
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 65143a1..1a863a4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2023,6 +2023,7 @@ static int _lvconvert_split_cached(struct cmd_context *cmd,
 	return 1;
 }
 
+#if 0
 static int _lvconvert_splitcache(struct cmd_context *cmd,
 				 struct logical_volume *lv,
 				 struct lvconvert_params *lp)
@@ -2050,7 +2051,9 @@ static int _lvconvert_splitcache(struct cmd_context *cmd,
 
 	return 1;
 }
+#endif
 
+#if 0
 static int _lvconvert_split(struct cmd_context *cmd,
 			    struct logical_volume *lv,
 			    struct lvconvert_params *lp)
@@ -2080,6 +2083,7 @@ static int _lvconvert_split(struct cmd_context *cmd,
 
 	return 1;
 }
+#endif
 
 static int _lvconvert_uncache(struct cmd_context *cmd,
 			      struct logical_volume *lv,
@@ -3337,6 +3341,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	return 1;
 }
 
+#if 0
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvconvert_params *lp)
 {
@@ -3493,6 +3498,787 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 	return ECMD_PROCESSED;
 }
+#endif
+
+/*
+ * Functions called to perform a specific operation on a specific LV type.
+ *
+ * _convert_<lvtype>_<operation>
+ *
+ * For cases where an operation does not apply to the LV itself, but
+ * is implicitly redirected to a sub-LV, these functions locate the
+ * correct sub-LV and call the operation on that sub-LV.  If a sub-LV
+ * of the proper type is not found, these functions report the error.
+ *
+ * FIXME: the _lvconvert_foo() functions can be cleaned up since they
+ * are now only called for valid combinations of LV type and operation.
+ * After that happens, the code remaining in those functions can be
+ * moved into the _convert_lvtype_operation() functions below.
+ */
+
+static int _convert_cow_snapshot_splitsnapshot(struct cmd_context *cmd, struct logical_volume *lv,
+			                       struct lvconvert_params *lp)
+{
+	return _lvconvert_splitsnapshot(cmd, lv, lp);
+}
+
+static int _convert_cow_snapshot_merge(struct cmd_context *cmd, struct logical_volume *lv,
+			               struct lvconvert_params *lp)
+{
+	return _lvconvert_merge_old_snapshot(cmd, lv, lp);
+}
+
+static int _convert_thin_volume_merge(struct cmd_context *cmd, struct logical_volume *lv,
+			              struct lvconvert_params *lp)
+{
+	return _lvconvert_merge_thin_snapshot(cmd, lv, lp);
+}
+
+static int _convert_thin_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
+				         struct lvconvert_params *lp)
+{
+	struct logical_volume *sublv1;
+
+	sublv1 = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
+
+	if (!lv_is_cache(sublv1)) {
+		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
+		return 0;
+	}
+
+	return _lvconvert_split_cached(cmd, sublv1);
+}
+
+static int _convert_thin_pool_uncache(struct cmd_context *cmd, struct logical_volume *lv,
+				      struct lvconvert_params *lp)
+{
+	struct logical_volume *sublv1 = NULL;
+
+	sublv1 = seg_lv(first_seg(lv), 0); /* cached _tdata ? */
+
+	if (!lv_is_cache(sublv1)) {
+		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
+		return 0;
+	}
+
+	return _lvconvert_uncache(cmd, sublv1, lp);
+}
+
+static int _convert_thin_pool_repair(struct cmd_context *cmd, struct logical_volume *lv,
+			             struct lvconvert_params *lp)
+{
+	return _lvconvert_thin_pool_repair(cmd, lv, lp);
+}
+
+static int _convert_thin_pool_cache(struct cmd_context *cmd, struct logical_volume *lv,
+			            struct lvconvert_params *lp)
+{
+	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
+	if (!_lvconvert_pool(cmd, lv, lp)) {
+		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
+		return 0;
+	}
+
+	/* Do we need to grab the tdata sub LV to pass on? */
+
+	return _lvconvert_cache(cmd, lv, lp);
+}
+
+static int _convert_thin_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
+			                   struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_cache_volume_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
+			                    struct lvconvert_params *lp)
+{
+	return _lvconvert_split_cached(cmd, lv);
+}
+
+static int _convert_cache_volume_uncache(struct cmd_context *cmd, struct logical_volume *lv,
+			                 struct lvconvert_params *lp)
+{
+	return _lvconvert_uncache(cmd, lv, lp);
+}
+
+static int _convert_cache_volume_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
+			                     struct lvconvert_params *lp)
+{
+	struct logical_volume *sublv1;
+
+	sublv1 = seg_lv(first_seg(lv), 0);
+
+	if (lv_is_raid(sublv1))
+		return _lvconvert_raid(sublv1, lp);
+
+	if (lv_is_mirror(sublv1))
+		return _lvconvert_mirrors(cmd, lv, lp);
+
+	log_error("Sub LV %s must be raid or mirror.", display_lvname(sublv1));
+	return 0;
+}
+
+static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			                   struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_cache_pool_splitcache(struct cmd_context *cmd, struct logical_volume *lv,
+					  struct lvconvert_params *lp)
+{
+	struct logical_volume *sublv1;
+	struct lv_segment *seg;
+
+	/* When passed used cache-pool of used cached LV -> split cached LV */
+
+	if ((dm_list_size(&lv->segs_using_this_lv) == 1) &&
+	    (seg = get_only_segment_using_this_lv(lv)) &&
+	    seg_is_cache(seg))
+		sublv1 = seg->lv;
+	else {
+		log_error("Sub LV of cache type not found.");
+		return 0;
+	}
+
+	if (!lv_is_cache(sublv1)) {
+		log_error("Sub LV %s must be cache.", display_lvname(sublv1));
+		return 0;
+	}
+
+	return _lvconvert_split_cached(cmd, sublv1);
+}
+
+static int _convert_cache_pool_swapmetadata(struct cmd_context *cmd, struct logical_volume *lv,
+			                    struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_mirror_number(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
+
+static int _convert_mirror_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
+			                struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
+
+static int _convert_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
+
+static int _convert_mirror_repair(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	struct dm_list *failed_pvs;
+	int ret;
+
+	ret = _lvconvert_mirrors_repair(cmd, lv, lp);
+
+	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
+		if ((failed_pvs = _failed_pv_list(lv->vg)))
+			_remove_missing_empty_pv(lv->vg, failed_pvs);
+	}
+
+	return ret;
+}
+
+static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			        struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_number(struct cmd_context *cmd, struct logical_volume *lv,
+			        struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_splitmirrors(struct cmd_context *cmd, struct logical_volume *lv,
+			    	      struct lvconvert_params *lp)
+{
+	/* FIXME: split the splitmirrors section out of _lvconvert_raid and call it here. */
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_merge(struct cmd_context *cmd, struct logical_volume *lv,
+			       struct lvconvert_params *lp)
+{
+	/* FIXME: split the merge section out of _lvconvert_raid and call it here. */
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_repair(struct cmd_context *cmd, struct logical_volume *lv,
+			        struct lvconvert_params *lp)
+{
+	struct dm_list *failed_pvs;
+	int ret;
+
+	/* FIXME: split the repair section out of _lvconvert_raid and call it here. */
+	ret = _lvconvert_raid(lv, lp);
+
+	if (ret && arg_is_set(cmd, usepolicies_ARG)) {
+		if ((failed_pvs = _failed_pv_list(lv->vg)))
+			_remove_missing_empty_pv(lv->vg, failed_pvs);
+	}
+
+	return ret;
+}
+
+static int _convert_raid_replace(struct cmd_context *cmd, struct logical_volume *lv,
+			         struct lvconvert_params *lp)
+{
+	/* FIXME: remove the replace section from _lvconvert_raid */
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	return _lvconvert_snapshot(cmd, lv, lp);
+}
+
+static int _convert_raid_thin(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
+	if (!_lvconvert_pool(cmd, lv, lp)) {
+		log_error("Implicit conversion of --thinpool arg to type thin-pool failed.");
+		return 0;
+	}
+
+	return _lvconvert_thin(cmd, lv, lp);
+}
+
+static int _convert_raid_cache(struct cmd_context *cmd, struct logical_volume *lv,
+			       struct lvconvert_params *lp)
+{
+	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
+	if (!_lvconvert_pool(cmd, lv, lp)) {
+		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
+		return 0;
+	}
+
+	return _lvconvert_cache(cmd, lv, lp);
+}
+
+static int _convert_raid_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			           struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_raid_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			            struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
+			         struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,
+			        struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_striped_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
+			             struct lvconvert_params *lp)
+{
+	return _lvconvert_snapshot(cmd, lv, lp);
+}
+
+static int _convert_striped_merge(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume *lv,
+			         struct lvconvert_params *lp)
+{
+	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
+	if (!_lvconvert_pool(cmd, lv, lp)) {
+		log_error("Implicit conversion of --thinpool arg to type thin-pool failed.");
+		return 0;
+	}
+
+	return _lvconvert_thin(cmd, lv, lp);
+}
+
+static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume *lv,
+			          struct lvconvert_params *lp)
+{
+	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
+	if (!_lvconvert_pool(cmd, lv, lp)) {
+		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
+		return 0;
+	}
+
+	return _lvconvert_cache(cmd, lv, lp);
+}
+
+static int _convert_striped_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			              struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_striped_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			               struct lvconvert_params *lp)
+{
+	return _lvconvert_pool(cmd, lv, lp);
+}
+
+static int _convert_striped_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			           struct lvconvert_params *lp)
+{
+	return _lvconvert_mirrors(cmd, lv, lp);
+}
+
+static int _convert_striped_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			         struct lvconvert_params *lp)
+{
+	return _lvconvert_raid(lv, lp);
+}
+
+/*
+ * Functions called to perform all valid operations on a given LV type.
+ *
+ * _convert_<lvtype>
+ */
+
+static int _convert_cow_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
+		                 struct lvconvert_params *lp)
+{
+	if (lp->splitsnapshot)
+		return _convert_cow_snapshot_splitsnapshot(cmd, lv, lp);
+
+	if (lp->merge)
+		return _convert_cow_snapshot_merge(cmd, lv, lp);
+
+	log_error("Operation not permitted on COW snapshot LV %s", display_lvname(lv));
+	log_error("Operations permitted on a COW snapshot LV are:\n"
+		  "  --splitsnapshot\n"
+		  "  --merge\n");
+	return 0;
+}
+
+static int _convert_thin_volume(struct cmd_context *cmd, struct logical_volume *lv,
+				struct lvconvert_params *lp)
+{
+	if (lp->merge)
+		return _convert_thin_volume_merge(cmd, lv, lp);
+
+	log_error("Operation not permitted on thin LV %s", display_lvname(lv));
+	log_error("Operations permitted on a thin LV are:\n"
+		  "  --merge\n");
+	return 0;
+}
+
+static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			      struct lvconvert_params *lp)
+{
+	if (lp->splitcache || lp->split)
+		return _convert_thin_pool_splitcache(cmd, lv, lp);
+
+	if (lp->uncache)
+		return _convert_thin_pool_uncache(cmd, lv, lp);
+
+	if (lp->cache)
+		return _convert_thin_pool_cache(cmd, lv, lp);
+
+	if (lp->repair)
+		return _convert_thin_pool_repair(cmd, lv, lp);
+
+	/* FIXME: swapping the thin pool metadata LV needs a specific option like --swapmetadata */
+	if (arg_is_set(cmd, poolmetadata_ARG))
+		return _convert_thin_pool_swapmetadata(cmd, lv, lp);
+
+	/* FIXME: add --swapmetadata to list of permitted operations. */
+
+	log_error("Operation not permitted on thin pool LV %s", display_lvname(lv));
+	log_error("Operations permitted on a thin pool LV are:\n"
+		  "  --splitcache   (operates on cache sub LV)\n"
+		  "  --uncache      (operates on cache sub LV)\n"
+		  "  --cache        (operates on data sub LV)\n"
+		  "  --repair\n");
+	return 0;
+}
+
+static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume *lv,
+			         struct lvconvert_params *lp)
+{
+	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
+
+	if (lp->splitcache || lp->split)
+		return _convert_cache_volume_splitcache(cmd, lv, lp);
+
+	if (lp->uncache)
+		return _convert_cache_volume_uncache(cmd, lv, lp);
+
+	/* FIXME: add lp->splitmirrors to reflect the arg. */
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "thin-pool"))
+		return _convert_cache_volume_thin_pool(cmd, lv, lp);
+
+	log_error("Operation not permitted on cache LV %s", display_lvname(lv));
+	log_error("Operations permitted on a cache LV are:\n"
+		  "  --splitcache\n"
+		  "  --uncache\n"
+		  "  --splitmirrors (operates on mirror or raid sub LV)\n"
+		  "  --type thin-pool\n");
+	return 0;
+}
+
+static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *lv,
+			       struct lvconvert_params *lp)
+{
+	if (lp->splitcache || lp->split)
+		return _convert_cache_pool_splitcache(cmd, lv, lp);
+
+	/* FIXME: swapping the cache pool metadata LV needs a specific option like --swapmetadata */
+	if (arg_is_set(cmd, poolmetadata_ARG))
+		return _convert_cache_pool_swapmetadata(cmd, lv, lp);
+
+	/* FIXME: add --swapmetadata to list of permitted operations. */
+
+	log_error("Operation not permitted on cache pool LV %s", display_lvname(lv));
+	log_error("Operations permitted on a cache pool LV are:\n"
+		  "  --splitcache        (operates on cache LV)\n");
+	return 0;
+}
+
+static int _convert_mirror(struct cmd_context *cmd, struct logical_volume *lv,
+			   struct lvconvert_params *lp)
+{
+	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
+	const struct segment_type *new_segtype = NULL;
+
+	if (new_type)
+		new_segtype = get_segtype_from_string(cmd, new_type);
+
+	if (lp->mirrors_supplied)
+		return _convert_mirror_number(cmd, lv, lp);
+
+	/* FIXME: add lp->splitmirrors to reflect the arg. */
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_mirror_splitmirrors(cmd, lv, lp);
+
+	if (lp->mirrorlog || lp->corelog)
+		return _convert_mirror_log(cmd, lv, lp);
+
+	if (lp->repair)
+		return _convert_mirror_repair(cmd, lv, lp);
+
+	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+		return _convert_mirror_raid(cmd, lv, lp);
+
+	/*
+	 * FIXME: this is here to preserve old behavior, but an
+	 * explicit option should be added to enable this case,
+	 * rather than making it the result of an ambiguous
+	 * "lvconvert vg/lv" command.
+	 *
+	 * Old behavior was described as:
+	 *   "Collapsing a stack of mirrors.
+	 *    If called with no argument, try collapsing the resync layers"
+	 */
+	log_debug("Checking if LV %s is converting.", display_lvname(lv));
+	if (lv_is_converting(lv)) {
+		lp->need_polling = 1;
+		return 1;
+	}
+
+	log_error("Operation not permitted on mirror LV %s", display_lvname(lv));
+	log_error("Operations permitted on a mirror LV are:\n"
+		  "  --mirrors\n"
+		  "  --splitmirrors\n"
+		  "  --mirrorlog\n"
+		  "  --repair\n"
+		  "  --type raid*\n");
+	return 0;
+}
+
+static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
+			 struct lvconvert_params *lp)
+{
+	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
+	const struct segment_type *new_segtype = NULL;
+
+	if (new_type)
+		new_segtype = get_segtype_from_string(cmd, new_type);
+
+	if (lp->mirrors_supplied)
+		return _convert_raid_number(cmd, lv, lp);
+
+	/* FIXME: add lp->splitmirrors to reflect the arg. */
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_raid_splitmirrors(cmd, lv, lp);
+
+	if (lp->merge_mirror)
+		return _convert_raid_merge(cmd, lv, lp);
+
+	if (lp->repair)
+		return _convert_raid_repair(cmd, lv, lp);
+
+	if (lp->replace)
+		return _convert_raid_replace(cmd, lv, lp);
+
+	if (lp->snapshot)
+		return _convert_raid_snapshot(cmd, lv, lp);
+
+	if (lp->thin)
+		return _convert_raid_thin(cmd, lv, lp);
+
+	if (lp->cache)
+		return _convert_raid_cache(cmd, lv, lp);
+
+	/* The --thinpool alias is ambiguous and not preferred. */
+
+	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
+		return _convert_raid_thin_pool(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "cache-pool"))
+		return _convert_raid_cache_pool(cmd, lv, lp);
+
+	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+		return _convert_raid_raid(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "striped"))
+		return _convert_raid_striped(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "linear"))
+		return _convert_raid_linear(cmd, lv, lp);
+
+	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+
+	log_error("Operation not permitted on raid LV %s", display_lvname(lv));
+	log_error("Operations permitted on a raid LV are:\n"
+		  "  --mirrors\n"
+		  "  --splitmirrors\n"
+		  "  --merge\n"
+		  "  --repair\n"
+		  "  --replace\n"
+		  "  --snapshot\n"
+		  "  --thin\n"
+		  "  --cache\n"
+		  "  --type thin-pool\n"
+		  "  --type cache-pool\n"
+		  "  --type raid*\n"
+		  "  --type striped\n"
+		  "  --type linear\n");
+	return 0;
+}
+
+static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
+			    struct lvconvert_params *lp)
+{
+	const char *new_type = arg_str_value(cmd, type_ARG, NULL);
+	const struct segment_type *new_segtype = NULL;
+	const char *mirrors_type = find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL);
+
+	if (new_type)
+		new_segtype = get_segtype_from_string(cmd, new_type);
+
+	if (lp->snapshot)
+		return _convert_striped_snapshot(cmd, lv, lp);
+
+	/* FIXME: add a new option to make this case more clear, e.g. --merge-splitmirror */
+	if (lp->merge)
+		return _convert_striped_merge(cmd, lv, lp);
+
+	if (lp->thin)
+		return _convert_striped_thin(cmd, lv, lp);
+
+	if (lp->cache)
+		return _convert_striped_cache(cmd, lv, lp);
+
+	/* The --thinpool alias is ambiguous and not preferred. */
+
+	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
+		return _convert_striped_thin_pool(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "cache-pool"))
+		return _convert_striped_cache_pool(cmd, lv, lp);
+
+	if (new_type && !strcmp(new_type, "mirror"))
+		return _convert_striped_mirror(cmd, lv, lp);
+
+	if (new_type && new_segtype && segtype_is_raid(new_segtype))
+		return _convert_striped_raid(cmd, lv, lp);
+
+	/* --mirrors can mean --type mirror or --type raid1 depending on config setting. */
+
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, "mirror"))
+		return _convert_striped_mirror(cmd, lv, lp);
+
+	if (arg_is_set(cmd, mirrors_ARG) && mirrors_type && !strcmp(mirrors_type, "raid1"))
+		return _convert_striped_raid(cmd, lv, lp);
+
+	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+
+	log_error("Operation not permitted on striped or linear LV %s", display_lvname(lv));
+	log_error("Operations permitted on a striped or linear LV are:\n"
+		  "  --snapshot\n"
+		  "  --merge\n"
+		  "  --thin\n"
+		  "  --cache\n"
+		  "  --type thin-pool\n"
+		  "  --type cache-pool\n"
+		  "  --type mirror | --mirrors\n"
+		  "  --type raid* | --mirrors\n");
+	return 0;
+}
+
+/*
+ * lvconvert performs a specific <operation> on a specific <lv_type>.
+ *
+ * The <operation> is specified by command args found in lp fields.
+ * The <lv_type> is found using lv_is_foo(lv) functions.
+ *
+ * lvconvert --operation LV
+ *
+ * lp->operation = arg_value(operation);
+ * lv_type = lv_is_foo(LV);
+ *
+ * for each lvtype,
+ *     _convert_lvtype();
+ *         for each lp->operation
+ *             _convert_lvtype_operation();
+ */
+
+static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
+		      struct lvconvert_params *lp)
+{
+	struct lv_segment *lv_seg = first_seg(lv);
+	int ret = 0;
+
+	log_debug("lvconvert lv %s is type %s status %llx to type %s",
+		  display_lvname(lv),
+		  lv_seg->segtype->name,
+		  (unsigned long long)lv->status,
+		  arg_str_value(cmd, type_ARG, ""));
+
+	/*
+	 * Check some conditions that can never be processed.
+	 */
+
+	if (lv_is_locked(lv)) {
+		log_error("Cannot convert locked LV %s.", display_lvname(lv));
+		ret = 0;
+		goto out;
+	}
+
+	if (lv_is_pvmove(lv)) {
+		log_error("Cannot convert pvmove LV %s.", display_lvname(lv));
+		ret = 0;
+		goto out;
+	}
+
+	if (!lv_is_visible(lv)) {
+		/*
+		 * FIXME: there are some exceptions to the rule of only
+		 * operating on visible LVs.  These should be fixed by running
+		 * the command on the visible LV with an option indicating
+		 * which sub LV is intended rather than naming the !visible LV.
+		 */
+		if (!lv_is_cache_pool_metadata(lv) &&
+		    !lv_is_cache_pool_data(lv) &&
+		    !lv_is_thin_pool_metadata(lv) &&
+		    !lv_is_thin_pool_data(lv) &&
+		    !lv_is_raid_image(lv)) {
+			log_error("Cannot convert internal LV %s.", display_lvname(lv));
+			ret = 0;
+			goto out;
+		}
+	}
+
+	/*
+	 * Each LV type that can be converted.
+	 * (The existing type of the LV, not a requested type.)
+	 */
+
+	if (lv_is_cow(lv)) {
+		ret = _convert_cow_snapshot(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_thin_volume(lv)) {
+		ret = _convert_thin_volume(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_thin_pool(lv)) {
+		ret = _convert_thin_pool(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_cache(lv)) {
+		ret = _convert_cache_volume(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_cache_pool(lv)) {
+		ret = _convert_cache_pool(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_mirror(lv)) {
+		ret = _convert_mirror(cmd, lv, lp);
+		goto out;
+	}
+
+	if (lv_is_raid(lv)) {
+		ret = _convert_raid(cmd, lv, lp);
+		goto out;
+	}
+
+	/*
+	 * FIXME: add lv_is_striped() and lv_is_linear()?
+	 * This does not include raid0.
+	 * If operations differ between striped and linear, split this case.
+	 */
+	if (segtype_is_striped(lv_seg->segtype) || segtype_is_linear(lv_seg->segtype)) {
+		ret = _convert_striped(cmd, lv, lp);
+		goto out;
+	}
+
+	/*
+	 * Check for LV types that cannot be converted and print an error.
+	 */
+
+	/*
+	 * The intention is to explicitly check all cases above and never
+	 * reach here, but this covers anything that was missed.
+	 */
+	log_error("Cannot convert LV %s.", display_lvname(lv));
+	ret = 0;
+
+out:
+	return ret ? ECMD_PROCESSED : ECMD_FAILED;
+
+}
 
 static struct convert_poll_id_list* _convert_poll_id_list_create(struct cmd_context *cmd,
 								 const struct logical_volume *lv)


