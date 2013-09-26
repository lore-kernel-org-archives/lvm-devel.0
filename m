From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Sep 2013 03:34:00 +0000 (UTC)
Subject: master - mirror/RAID: Honor mirror_segtype_default when converting from linear
Message-ID: <20130926033400.2D53D6074C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=098896fb2905cd02d02b7271be489e32d86c073d
Commit:        098896fb2905cd02d02b7271be489e32d86c073d
Parent:        dd796d6a9485287973e61c427ee45694965203a0
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 25 22:25:43 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 25 22:25:43 2013 -0500

mirror/RAID: Honor mirror_segtype_default when converting from linear

1) When converting from an x-way mirror/raid1 to a y-way mirror/raid1,
the default behaviour should be to stay the same segment type.

2) When converting from linear to mirror or raid1, the default behaviour
should honor the mirror_segtype_default.

3) When converting and the '--type' argument is specified, the '--type'
argument should be honored.

catch such conditions, but errors in the tests caused the issue to go
unnoticed.  The code has been fixed to perform #2 properly, the tests
have been corrected to properly test for #2, and a few other tests
were changed to explicitly specify the '--type mirror' when necessary.
---
 test/shell/lvconvert-mirror-basic.sh |    2 +-
 test/shell/lvconvert-mirror.sh       |   21 +++++++++++----------
 test/shell/lvconvert-raid.sh         |    4 ++--
 tools/lvconvert.c                    |   14 +++++++++++++-
 4 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index caee9db..28258b2 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -92,7 +92,7 @@ test_lvconvert() {
 		alloc="--alloc anywhere"
 	fi
 
-	lvconvert -m $finish_count --mirrorlog $finish_log_type \
+	lvconvert --type mirror -m $finish_count --mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
 	test $active || lvchange -aey $vg/$lv1
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 600bbec..911e022 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -20,14 +20,14 @@ vgcreate -s 32k $vg $(cat DEVICES)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
 	--config 'global { mirror_segtype_default = "mirror" }'
-check mirror $vg $lv1 "$dev3"
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*m'
 lvremove -ff $vg
 
 # convert from linear to 2-way mirror (override "raid1" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 lvconvert -i1 --type mirror -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
 	--config 'global { mirror_segtype_default = "raid1" }'
-check mirror $vg $lv1 "$dev3"
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*m'
 lvremove -ff $vg
 
 # convert from linear to 2-way mirror - with tags and volume_list (bz683270)
@@ -204,16 +204,17 @@ lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
 
-# "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
+# "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute
+# after being down and the up converted"
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 --nosync $vg
 lvconvert -m0 $vg/$lv1
-lvconvert -m1 $vg/$lv1
-lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
+lvconvert --type mirror -m1 $vg/$lv1
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*m'
 lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
 lvcreate -aey -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
-lvconvert -m1 $vg/$lv1
+lvconvert --type mirror -m1 $vg/$lv1
 
 should check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
@@ -222,7 +223,7 @@ lvremove -ff $vg
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
 lvcreate -aey -l1 --type mirror -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
-lvconvert -m1 --mirrorlog disk $vg/$lv1
+lvconvert --type mirror -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
 not check mirror $vg $lv1 core
 lvremove -ff $vg
@@ -243,14 +244,14 @@ lvremove -ff $vg
 
 # simple mirrored stripe
 lvcreate -aey -i2 -l10 -n $lv1 $vg
-lvconvert -m1 -i1 $vg/$lv1
+lvconvert --type mirror -m1 -i1 $vg/$lv1
 lvreduce -f -l1 $vg/$lv1
 lvextend -f -l10 $vg/$lv1
 lvremove -ff $vg/$lv1
 
 # extents must be divisible
 lvcreate -aey -l15 -n $lv1 $vg
-not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
+not lvconvert --type mirror -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
 
 test -e LOCAL_CLVMD && exit 0
@@ -258,7 +259,7 @@ test -e LOCAL_CLVMD && exit 0
 # FIXME - cases which needs to be fixed to work in cluster
 # Linear to mirror with mirrored log using --alloc anywhere
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
-lvconvert -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
+lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 should check mirror $vg $lv1
 lvremove -ff $vg
 
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6762db2..680710e 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -142,7 +142,7 @@ lvremove -ff $vg
 lvcreate -aey -l 2 -n $lv1 $vg
 lvconvert -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "raid1" }'
-lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
 lvremove -ff $vg
 
 ###########################################
@@ -151,7 +151,7 @@ lvremove -ff $vg
 lvcreate -aey -l 2 -n $lv1 $vg
 lvconvert --type raid1 -m 1 $vg/$lv1 \
 	--config 'global { mirror_segtype_default = "mirror" }'
-lvs --noheadings -o attr $vg/$lv1 | grep '^r*'
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
 lvremove -ff $vg
 
 ###########################################
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index bbcfff7..ebb5138 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2570,9 +2570,21 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (!lp->segtype)
+	if (!lp->segtype) {
+		/* segtype not explicitly set in _read_params */
 		lp->segtype = first_seg(lv)->segtype;
 
+		/*
+		 * If we are converting to mirror/raid1 and
+		 * the segtype was not specified, then we need
+		 * to consult the default.
+		 */
+		if (arg_count(cmd, mirrors_ARG) && !lv_is_mirrored(lv)) {
+			lp->segtype = get_segtype_from_string(cmd, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL));
+			if (!lp->segtype)
+				return_0;
+		}
+	}
 	if (lp->merge) {
 		if (!lv_is_cow(lv)) {
 			log_error("\"%s\" is not a mergeable logical volume",


