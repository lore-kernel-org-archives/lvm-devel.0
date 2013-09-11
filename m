From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 11 Sep 2013 20:59:31 +0000 (UTC)
Subject: master - Mirror/Thin: Disallow thinpools on mirror logical volumes
Message-ID: <20130911205932.0324F60FFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82228acfc95fa4dbe9acca2d3bfc5a89087fd5e4
Commit:        82228acfc95fa4dbe9acca2d3bfc5a89087fd5e4
Parent:        1f4bc637b4b71ed7a66ea4e7836c51b529bef92a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 11 15:58:44 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 11 15:58:44 2013 -0500

Mirror/Thin: Disallow thinpools on mirror logical volumes

The same corner cases that exist for snapshots on mirrors exist for
any logical volume layered on top of mirror.  (One example is when
a mirror image fails and a non-repair LVM command is the first to
detect it via label reading.  In this case, the LVM command will hang
and prevent the necessary LVM repair command from running.)  When
a better alternative exists, it makes no sense to allow a new target
to stack on mirrors as a new feature.  Since, RAID is now capable of
running EX in a cluster and thin is not active-active aware, it makes
sense to pair these two rather than mirror+thinpool.

As further background, here are some additional comments that I made
when addressing a bug related to mirror+thinpool:
(https://bugzilla.redhat.com/show_bug.cgi?id=919604#c9)
I am going to disallow thin* on top of mirror logical volumes.
Users will have to use the "raid1" segment type if they want this.

This bug has come down to a choice between:
1) Disallowing thin-LVs from being used as PVs.
2) Disallowing thinpools on top of mirrors.

The problem is that the code in dev_manager.c:device_is_usable() is unable
to tell whether there is a mirror device lower in the stack from the device
being checked.  Pretty much anything layered on top of a mirror will suffer
from this problem.  (Snapshots are a good example of this; and option #1
above has been chosen to deal with them.  This can also be seen in
dev_manager.c:device_is_usable().)  When a mirror failure occurs, the
kernel blocks all I/O to it.  If there is an LVM command that comes along
to do the repair (or a different operation that requires label reading), it
would normally avoid the mirror when it sees that it is blocked.  However,
if there is a snapshot or a thin-LV that is on a mirror, the above code
will not detect the mirror underneath and will issue label reading I/O.
This causes the command to hang.

Choosing #1 would mean that thin-LVs could never be used as PVs - even if
they are stacked on something other than mirrors.

Choosing #2 means that thinpools can never be placed on mirrors.  This is
probably better than we think, since it is preferred that people use the
"raid1" segment type in the first place.  However, RAID* cannot currently
be used in a cluster volume group - even in EX-only mode.  Thus, a complete
solution for option #2 must include the ability to activate RAID logical
volumes (and perform RAID operations) in a cluster volume group.  I've
already begun working on this.
---
 WHATS_NEW                    |    1 +
 test/shell/lvchange-raid.sh  |    7 +++++++
 test/shell/lvconvert-thin.sh |   20 +++++++++++++++-----
 tools/lvconvert.c            |   19 +++++++++++++++++++
 4 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 927419a..2245d56 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Disallow thinpools on mirror logical volumes.
   Direct udev to use 3min timeout for LVM devices. Recent udev has default 30s.
   Do not scan multipath or RAID components and avoid incorrect autoactivation.
   Fix MD/loop udev handling to fire autoactivation after setup or coldplug only.
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index babe726..f1b8d72 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -285,6 +285,12 @@ run_checks() {
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_data' == $3 ]; then
 		aux target_at_least dm-thin-pool 1 8 0 || return 0
+
+		# RAID works EX in cluster
+		# thinpool works EX in cluster
+		# but they don't work together in a cluster yet
+		#  (nor does thinpool+mirror work in a cluster yet)
+		test -e LOCAL_CLVMD && return 0
 		printf "#\n#\n# run_checks: RAID as thinpool data\n#\n#\n"
 
 # Hey, specifying devices for thin allocation doesn't work
@@ -300,6 +306,7 @@ run_checks() {
 		run_recovery_rate_check $1 $2
 	elif [ 'thinpool_meta' == $3 ]; then
 		aux target_at_least dm-thin-pool 1 8 0 || return 0
+		test -e LOCAL_CLVMD && return 0
 		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
 		lvrename $1/$2 ${2}_meta
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index f1e2176..0081e45 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -36,13 +36,22 @@ vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
 
 # create mirrored LVs for data and metadata volumes
 lvcreate -aey -L10M --type mirror -m1 --mirrorlog core -n $lv1 $vg
-lvcreate -aey -L8M --type mirror -m1 --mirrorlog core -n $lv2 $vg
+lvcreate -aey -L10M -n $lv2 $vg
 lvchange -an $vg/$lv1
 
+# conversion fails for mirror segment type
+not lvconvert --thinpool $vg/$lv1
+not lvconvert --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
+lvremove -f $vg
+
+# create RAID LVs for data and metadata volumes
+lvcreate -aey -L10M --type raid1 -m1 -n $lv1 $vg
+lvcreate -aey -L10M --type raid1 -m1 -n $lv2 $vg
+lvchange -an $vg/$lv1
 
 # conversion fails for internal volumes
-not lvconvert --thinpool $vg/${lv1}_mimage_0
-not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_mimage_0
+not lvconvert --thinpool $vg/${lv1}_rimage_0
+not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 # can't use --readahead with --poolmetadata
 not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
 
@@ -95,7 +104,8 @@ grep "WARNING: Chunk size is too small" err
 
 #lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
-# Convertions of pool to mirror is unsupported
-not lvconvert -m1 $vg/$lv1
+# Convertions of pool to mirror or RAID is unsupported
+not lvconvert --type mirror -m1 $vg/$lv1
+not lvconvert --type raid1 -m1 $vg/$lv1
 
 vgremove -ff $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 13002e3..2a3c827 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1605,6 +1605,13 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	if (!_lvconvert_validate_thin(lv, lp))
 		return_0;
 
+	if (lv_is_thin_type(lv)) {
+		log_error("Mirror segment type cannot be used for thinpool%s.\n"
+			  "Try \"raid1\" segment type instead.",
+			  lv_is_thin_pool_data(lv) ? "s" : " metadata");
+		return 0;
+	}
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,
@@ -2270,6 +2277,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
+		log_error("Mirror logical volumes cannot be used as thinpools.\n"
+			  "Try \"raid1\" segment type instead.");
+		return 0;
+	}
+
 	if (lp->thin) {
 		external_lv = pool_lv;
 		if (!(pool_lv = find_lv(external_lv->vg, lp->pool_data_lv_name))) {
@@ -2338,6 +2351,12 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  metadata_lv->vg->name, metadata_lv->name);
 			return 0;
 		}
+		if (lv_is_mirrored(pool_lv) && !lv_is_raid_type(pool_lv)) {
+			log_error("Mirror logical volumes cannot be used"
+				  " for thinpool metadata.\n"
+				  "Try \"raid1\" segment type instead.");
+			return 0;
+		}
 		if (metadata_lv->status & LOCKED) {
 			log_error("Can't convert locked LV %s/%s.",
 				  metadata_lv->vg->name, metadata_lv->name);


