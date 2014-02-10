From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Feb 2014 17:27:28 -0600
Subject: RAID: Allow implicit stripe (and parity) when creating RAID LVs
Message-ID: <1392074848.17667.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are typically 2 functions for the more advanced segment types that
deal with parameters in lvcreate.c: _get_*_params() and _check_*_params().
(Not all segment types name their functions according to this scheme.)
The former function is responsible for reading parameters before the VG
has been read.  The latter is for sanity checking and possibly setting
parameters after the VG has been read.

This patch adds a _check_raid_parameters() function that will determine
if the user has specified 'stripe' or 'mirror' parameters.  If not, the
proper number is computed from the list of PVs the user has supplied or
the number that are available in the VG.  Now that _check_raid_parameters()
is available, we move the check for proper number of stripes from
_get_* to _check_*.

This gives the user the ability to create RAID LVs as follows:
# 5-device RAID5, 4-data, 1-parity (i.e. implicit '-i 4')
~> lvcreate --type raid5 -L 100G -n lv vg /dev/sd[abcde]1

# 5-device RAID6, 3-data, 2-parity (i.e. implicit '-i 3')
~> lvcreate --type raid6 -L 100G -n lv vg /dev/sd[abcde]1

# If 5 PVs in VG, 5-device RAID5
~> lvcreate --type raid5 -L 100G -n lv vg


Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -617,20 +617,7 @@ static int _read_raid_params(struct lvcr
 		return 0;
 	}
 
-	/*
-	 * get_stripe_params is called before _read_raid_params
-	 * and already sets:
-	 *   lp->stripes
-	 *   lp->stripe_size
-	 *
-	 * For RAID 4/5/6/10, these values must be set.
-	 */
-	if (!segtype_is_mirrored(lp->segtype) &&
-	    (lp->stripes <= lp->segtype->parity_devs)) {
-		log_error("Number of stripes must be at least %d for %s",
-			  lp->segtype->parity_devs + 1, lp->segtype->name);
-		return 0;
-	} else if (!strcmp(lp->segtype->name, "raid10") && (lp->stripes < 2)) {
+	if (!strcmp(lp->segtype->name, "raid10") && (lp->stripes < 2)) {
 		if (arg_count(cmd, stripes_ARG)) {
 			/* User supplied the bad argument */
 			log_error("Segment type 'raid10' requires 2 or more stripes.");
@@ -1182,6 +1169,45 @@ static int _check_thin_parameters(struct
 	return 1;
 }
 
+static int _check_raid_parameters(struct volume_group *vg,
+				  struct lvcreate_params *lp,
+				  struct lvcreate_cmdline_params *lcp)
+{
+	int devs = lcp->pv_count ? lcp->pv_count : dm_list_size(&vg->pvs);
+	struct cmd_context *cmd = vg->cmd;
+
+	/*
+	 * If number of devices was not supplied, we can infer from
+	 * the PVs given.
+	 */
+	if (!seg_is_mirrored(lp)) {
+		if (!arg_count(cmd, stripes_ARG) &&
+		    (devs > 2 * lp->segtype->parity_devs))
+			lp->stripes = devs - lp->segtype->parity_devs;
+
+		if (!lp->stripe_size)
+			lp->stripe_size = find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+
+		if (lp->stripes <= lp->segtype->parity_devs) {
+			log_error("Number of stripes must be at least %d for %s",
+				  lp->segtype->parity_devs + 1,
+				  lp->segtype->name);
+			return 0;
+		}
+	} else if (!strcmp(lp->segtype->name, "raid10")) {
+		if (!arg_count(cmd, stripes_ARG))
+			lp->stripes = devs / lp->mirrors;
+		if (lp->stripes < 2) {
+			log_error("Unable to create RAID10 LV,"
+				  " insufficient number of devices.");
+			return 0;
+		}
+	}
+	/* 'mirrors' defaults to 2 - not the number of PVs supplied */
+
+	return 1;
+}
+
 /*
  * Ensure the set of thin parameters extracted from the command line is consistent.
  */
@@ -1247,6 +1273,9 @@ int lvcreate(struct cmd_context *cmd, in
 	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
 		goto_out;
 
+	if (seg_is_raid(&lp) && !_check_raid_parameters(vg, &lp, &lcp))
+		goto_out;
+
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
Index: lvm2/test/shell/lvcreate-raid.sh
===================================================================
--- lvm2.orig/test/shell/lvcreate-raid.sh
+++ lvm2/test/shell/lvcreate-raid.sh
@@ -11,6 +11,14 @@
 
 . lib/test
 
+lv_devices() {
+	local local_vg=$1
+	local local_lv=$2
+	local count=$3
+
+	[ $count == `lvs --noheadings -o devices $local_vg/$local_lv | sed s/,/' '/g | wc -w` ]
+}
+
 ########################################################
 # MAIN
 ########################################################
@@ -70,3 +78,35 @@ for i in raid4 \
 	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
+
+
+# Create RAID (implicit stripe count based on PV count)
+#######################################################
+
+# Not enough drives
+not lvcreate --type raid1 -l1 $vg $dev1
+not lvcreate --type raid5 -l2 $vg $dev1 $dev2
+not lvcreate --type raid6 -l3 $vg $dev1 $dev2 $dev3 $dev4
+not lvcreate --type raid10 -l2 $vg $dev1 $dev2 $dev3
+
+# Implicit count comes from #PVs given (always 2 for mirror though)
+lvcreate --type raid1 -l1 -n raid1 $vg $dev1 $dev2
+lv_devices $vg raid1 2
+lvcreate --type raid5 -l2 -n raid5 $vg $dev1 $dev2 $dev3
+lv_devices $vg raid5 3
+lvcreate --type raid6 -l3 -n raid6 $vg $dev1 $dev2 $dev3 $dev4 $dev5
+lv_devices $vg raid6 4
+lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3
+lv_devices $vg raid10 4
+lvremove -ff $vg
+
+# Implicit count comes from total #PVs in VG (always 2 for mirror though)
+lvcreate --type raid1 -l1 -n raid1 $vg
+lv_devices $vg raid1 2
+lvcreate --type raid5 -l2 -n raid5 $vg
+lv_devices $vg raid5 6
+lvcreate --type raid6 -l3 -n raid6 $vg
+lv_devices $vg raid6 6
+lvcreate --type raid10 -l2 -n raid10 $vg
+lv_devices $vg raid10 6
+lvremove -ff $vg



