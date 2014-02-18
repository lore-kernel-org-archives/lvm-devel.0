From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 18 Feb 2014 03:08:17 +0000 (UTC)
Subject: master - RAID: Allow implicit stripe (and parity) when creating RAID LVs
Message-ID: <20140218030817.2A1EA60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a00a7e33dc9919610e953456081b057c8b981f6
Commit:        6a00a7e33dc9919610e953456081b057c8b981f6
Parent:        0be6caba6e4251200eb888a2686ddf9af8065d6c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 17 20:18:23 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 17 20:18:23 2014 -0600

RAID: Allow implicit stripe (and parity) when creating RAID LVs

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

# If 5 PVs in VG, 4-data, 1-parity RAID5
~> lvcreate --type raid5 -L 100G -n lv vg

Considerations:
This patch only affects RAID.  It might also be useful to apply this to
the 'stripe' segment type.  LVM RAID may include RAID0 at some point in
the future and the implicit stripes would apply there.  It would be odd
to have RAID0 be able to auto-determine the stripe count while 'stripe'
could not.

The only draw-back of this patch that I can see is that there might be
less error checking.  Rather than informing the user that they forgot
to supply an argument (e.g. '-i'), the value would be computed and it
may differ from what the user actually wanted.  I don't see this as a
problem, because the user can check the device count after creation
and remove the LV if they have made an error.
---
 WHATS_NEW                   |    1 +
 man/lvcreate.8.in           |   14 +++++++++-
 test/shell/lvcreate-raid.sh |   39 +++++++++++++++++++++++++++++
 tools/lvcreate.c            |   57 ++++++++++++++++++++++++++++++++----------
 4 files changed, 95 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03a3b8a..39e8b88 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  lvcreate computes RAID4/5/6 stripes if not given from # of allocatable PVs.
   Fix merging of old snapshot into thin volume origin.
   Use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit.
   Do not use VG read/write state for LV read/write state.
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 029d8da..f03fd48 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -204,7 +204,11 @@ the extra devices which are necessary for parity are
 internally accounted for.  Specifying
 .BI \-i 3
 would use 3 devices for striped logical volumes,
-4 devices for RAID 4/5, and 5 devices for RAID 6.
+4 devices for RAID 4/5, and 5 devices for RAID 6.  Alternatively,
+RAID 4/5/6 will stripe across all PVs in the volume group or
+all of the PVs specified if the
+.B \-i
+argument is omitted.
 .TP
 .BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
@@ -491,8 +495,14 @@ a parity drive for a total of 4 devices) and a stripesize of 64KiB:
 .sp
 .B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n my_lv vg00
 
+Creates a RAID5 logical volume "vg00/my_lv", using all of the free
+space in the VG and spanning all the PVs in the VG:
+.sp
+.B lvcreate \-\-type raid5 \-l 100%FREE \-n my_lv vg00
+
 Creates a 5GiB RAID10 logical volume "vg00/my_lv", with 2 stripes on
-2 2-way mirrors.  Note that the \fB-i\fP and \fB-m\fP arguments behave differently.
+2 2-way mirrors.  Note that the \fB-i\fP and \fB-m\fP arguments behave
+differently.
 The \fB-i\fP specifies the number of stripes.
 The \fB-m\fP specifies the number of
 .B additional
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 2a1ed6d..3f467f5 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
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
@@ -154,3 +162,34 @@ lvcreate -l 18 -n lv $vg $dev1
 lvcreate -i 2 -l 100%FREE -n stripe $vg
 check lv_field $vg/stripe size "93.00m"
 lvremove -ff $vg
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
+lv_devices $vg raid6 5
+lvcreate --type raid10 -l2 -n raid10 $vg $dev1 $dev2 $dev3 $dev4
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
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index b413f34..67ea8c6 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -619,20 +619,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
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
@@ -1184,6 +1171,45 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
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
@@ -1249,6 +1275,9 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (seg_is_cache(&lp) && !_determine_cache_argument(vg, &lp))
 		goto_out;
 
+	if (seg_is_raid(&lp) && !_check_raid_parameters(vg, &lp, &lcp))
+		goto_out;
+
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?


