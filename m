From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 10 Mar 2017 08:38:07 -0500
Subject: master - tmp
Message-ID: <201703101338.v2ADc7q4022581@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6e667adbce7ecc4be25b0ab66f3a36ad3ecb3970
Commit:        6e667adbce7ecc4be25b0ab66f3a36ad3ecb3970
Parent:        59e57be54f9b4c9e83ec1ede480285965a7411eb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 10 14:27:38 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 10 14:27:50 2017 +0100

tmp

---
 lib/config/defaults.h     |   10 +++-------
 lib/metadata/raid_manip.c |   40 ++++++++++++++++++++++++++++++++++------
 man/lvmraid.7.in          |    5 +++--
 3 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5554c9c..1bfbf6f 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -66,13 +66,9 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
-/* Limited by kernel failed devices bitfield in superblock (raid4/5/6 MD max 253) */
-/*
- * FIXME: Increase these to 64 and further to the MD maximum
- *	  once the SubLVs split and name shift got enhanced
- */
-#define DEFAULT_RAID1_MAX_IMAGES 64
-#define DEFAULT_RAID_MAX_IMAGES 64
+/* Limited by kernel failed devices bitfield in superblock (raid4/5/6 MD max 253!) */
+#define DEFAULT_RAID1_MAX_IMAGES 253
+#define DEFAULT_RAID_MAX_IMAGES 253
 #define DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES 0 /* Don't stripe across all devices if not -i/--stripes given */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a8c2e19..9e9455a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4405,10 +4405,10 @@ static int _get_allowed_conversion_options(const struct lv_segment *seg_from,
 /*
  * Log any possible conversions for @lv
  */
-typedef int (*type_flag_fn_t)(uint64_t *processed_segtypes, void *data);
+typedef int (*type_flag_fn_t)(const struct logical_volume *lv, void *ref, void *data);
 
 /* Loop through pt->flags calling tfn with argument @data */
-static int _process_type_flags(const struct logical_volume *lv, struct possible_type *pt, uint64_t *processed_segtypes, type_flag_fn_t tfn, void *data)
+static int _process_type_flags(const struct logical_volume *lv, struct possible_type *pt, void *ref, type_flag_fn_t tfn, void *data)
 {
 	unsigned i;
 	uint64_t t;
@@ -4420,7 +4420,7 @@ static int _process_type_flags(const struct logical_volume *lv, struct possible_
 		if ((t & pt->possible_types) &&
 		    !(t & seg->segtype->flags) &&
 		     ((segtype = get_segtype_from_flag(lv->vg->cmd, t))))
-			if (!tfn(processed_segtypes, data ? : (void *) segtype))
+			if (!tfn(lv, ref, data ? : (void *) segtype))
 				return 0;
 	}
 
@@ -4428,7 +4428,7 @@ static int _process_type_flags(const struct logical_volume *lv, struct possible_
 }
 
 /* Callback to increment unsigned  possible conversion types in *data */
-static int _count_possible_conversions(uint64_t *processed_segtypes, void *data)
+static int _count_possible_conversions(const struct logical_volume *lv, void *ref, void *data)
 {
 	unsigned *possible_conversions = data;
 
@@ -4438,15 +4438,43 @@ static int _count_possible_conversions(uint64_t *processed_segtypes, void *data)
 }
 
 /* Callback to log possible conversion to segment type in *data */
-static int _log_possible_conversion(uint64_t *processed_segtypes, void *data)
+static int _log_possible_transitions(const struct logical_volume *lv, void *ref, void *data)
 {
 	struct segment_type *segtype = data;
+	char *segtype_name = dm_pool_strdup(lv->vg->vgmem, first_seg(lv)->segtype->name);
+	char *p = strchr(segtype_name, '_');
+	const char *from_name = ((struct segment_type *) ref)->name;
+	size_t len;
+
+	if (p)
+		*p = '\0';
+
+	len = strlen(segtype_name);
+	if (strcmp(from_name, segtype->name) &&
+	    strncmp(segtype_name, segtype->name, len))
+		log_error("   -> %s", segtype->name);
+
+	return 1;
+}
+
+/* Callback to log possible conversion to segment type in *data */
+static int _log_possible_conversion(const struct logical_volume *lv, void *processed_segtypes_ptr, void *data)
+{
+	struct segment_type *segtype = data;
+	struct possible_takeover_reshape_type *pt = NULL;
+	struct lv_segment seg;
+	uint64_t *processed_segtypes = processed_segtypes_ptr;
 
 	/* Already processed? */
 	if (!(~*processed_segtypes & segtype->flags))
 		return 1;
 
 	log_error("  %s", segtype->name);
+	seg.segtype = segtype;
+	seg.area_count = first_seg(lv)->area_count;
+	if ((pt = _get_possible_takeover_reshape_type(&seg, NULL, (struct possible_type *) pt)))
+		if (!_process_type_flags(lv, (struct possible_type *) pt, segtype, _log_possible_transitions, NULL))
+			return_0;
 
 	*processed_segtypes |= segtype->flags;
 
@@ -4478,7 +4506,7 @@ static int _log_possible_conversion_types(const struct logical_volume *lv, const
 	const char *alias;
 	uint64_t processed_segtypes = UINT64_C(0);
 
-	/* Count any possible segment types @seg an be directly converted to */
+	/* Count any possible segment types @seg can be directly converted to */
 	while ((pt = _get_possible_type(seg, NULL, 0, pt)))
 		if (!_process_type_flags(lv, pt, &processed_segtypes, _count_possible_conversions, &possible_conversions))
 			return_0;
diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 79e6fe0..0831db7 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -1052,8 +1052,8 @@ All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
 
-If the RaidLV should be restriped for performance reasons,
-convert the 3-way striped raid6_nr LV to 5-way-striped.
+For performance reasons the raid6_nr RaidLV can be restriped.
+Convert it from 3-way striped to 5-way-striped.
 
 .nf
 # lvconvert --stripes 5 -y tb/lv
@@ -1090,6 +1090,7 @@ convert the 3-way striped raid6_nr LV to 5-way-striped.
   [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
 .fi
 
+Stripes also can be removed from raid5 and 6.
 Convert the 5-way striped raid6_nr LV to 4-way-striped.
 The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.


