From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:09 +0000 (UTC)
Subject: dev-mornfall-activate - tests: test mirrors in clustered way
Message-ID: <20130604192809.5BD356142A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db2b65704cb3e6d2b17dbc775017b36d8a23b5bd
Commit:        db2b65704cb3e6d2b17dbc775017b36d8a23b5bd
Parent:        e9e7421c8ed4d86fe32937881e5020986207d0b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 21:11:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:42:32 2013 +0200

tests: test mirrors in clustered way

Make the clustered testing using cluster locking for most of the tests.
Use exclusive activation for mirrors and snapshot origins.
---
 test/shell/covercmd.sh                 |    2 +-
 test/shell/listings.sh                 |    6 +-
 test/shell/lvchange-mirror.sh          |    2 +-
 test/shell/lvconvert-mirror-basic.sh   |   17 +++--
 test/shell/lvconvert-mirror.sh         |  122 ++++++++++++++++++--------------
 test/shell/lvconvert-repair-replace.sh |   90 ++++++++++++------------
 test/shell/lvconvert-repair.sh         |   20 +++---
 test/shell/lvcreate-large-raid.sh      |    3 +-
 test/shell/lvcreate-large-raid10.sh    |    3 +-
 test/shell/lvcreate-operation.sh       |    7 ++-
 test/shell/lvcreate-pvtags.sh          |   12 ++--
 test/shell/lvcreate-raid.sh            |    4 +-
 test/shell/lvcreate-raid10.sh          |    4 +-
 test/shell/metadata-balance.sh         |   28 ++++----
 test/shell/metadata.sh                 |   10 ++--
 test/shell/nomda-missing.sh            |   16 ++--
 test/shell/pv-duplicate.sh             |    2 +-
 test/shell/pvcreate-metadata0.sh       |    6 +-
 test/shell/pvcreate-usage.sh           |    2 +-
 test/shell/pvremove-usage.sh           |    2 +-
 test/shell/tags.sh                     |   12 ++--
 test/shell/topology-support.sh         |   11 ++--
 test/shell/vgchange-maxlv.sh           |    8 +-
 test/shell/vgchange-sysinit.sh         |    7 +-
 test/shell/vgcreate-usage.sh           |   57 ++++++++-------
 test/shell/vgimportclone.sh            |    2 +-
 test/shell/vgmerge-operation.sh        |   24 +++---
 test/shell/vgmerge-usage.sh            |    4 +-
 test/shell/vgreduce-usage.sh           |   16 ++--
 test/shell/vgsplit-operation.sh        |   32 ++++----
 30 files changed, 280 insertions(+), 251 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index b77d378..04074c1 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -24,7 +24,7 @@ pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 pvcreate "$dev4"
 pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 
 if aux have_readline; then
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index b6e4dfa..8b9d082 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -29,7 +29,7 @@ test $(pvs --noheadings $(cat DEVICES) | wc -l) -eq 5
 #COMM pvs with segment attributes works even for orphans
 test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l) -eq 5
 
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
 pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
@@ -45,7 +45,7 @@ pvdisplay "$dev2"|grep "VG Name.*$vg"
 check pv_field "$dev2" vg_name $vg
 
 #COMM lvs displays snapshots (bz171215)
-lvcreate -l4 -n $lv1 $vg
+lvcreate -aey -l4 -n $lv1 $vg
 lvcreate -l4 -s -n $lv2 $vg/$lv1
 test $(lvs --noheadings $vg | wc -l) -eq 2
 # should lvs -a display cow && real devices? (it doesn't)
@@ -54,7 +54,7 @@ dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
-lvcreate -l4 -m2 -n $lv3 $vg
+lvcreate -aey -l4 -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 26656d4..9f4d190 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -17,7 +17,7 @@ aux prepare_vg 3
 # force resync 2-way active mirror
 lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 check mirror $vg $lv1 "$dev3"
-echo y | lvchange --resync $vg/$lv1
+lvchange -y --resync $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index a0f50f6..ed9a17e 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -76,12 +76,12 @@ test_lvconvert() {
 			alloc="--alloc anywhere"
 		fi
 
-		lvcreate -l2 -m $start_count --mirrorlog $start_log_type \
+		lvcreate -aey -l2 -m $start_count --mirrorlog $start_log_type \
 			-n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log
 	else
-		lvcreate -l2 -n $lv1 $vg
+		lvcreate -aey -l2 -n $lv1 $vg
 	fi
 
 	lvs -a -o name,copy_percent,devices $vg
@@ -95,7 +95,7 @@ test_lvconvert() {
 	lvconvert -m $finish_count --mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
-	test $active || lvchange -ay $vg/$lv1
+	test $active || lvchange -aey $vg/$lv1
 
 	check mirror_no_temporaries $vg $lv1
 	if [ "$finish_count_p1" -eq 1 ]; then
@@ -110,14 +110,19 @@ test_lvconvert() {
 	fi
 }
 
+
 aux prepare_pvs 5 5
-vgcreate -c n -s 128k $vg $(cat DEVICES)
+vgcreate -s 32k $vg $(cat DEVICES)
+
+MIRRORED="mirrored"
+# FIXME: Cluster is not supporting exlusive activation of mirrored log
+test -e LOCAL_CLVMD && MIRRORED=
 
 test_many() {
 	i=$1
 	for j in $(seq 0 3); do
-		for k in core disk mirrored; do
-			for l in core disk mirrored; do
+		for k in core disk $MIRRORED; do
+			for l in core disk $MIRRORED; do
 				if test "$i" -eq "$j" && test "$k" = "$l"; then continue; fi
 				: ----------------------------------------------------
 				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index c09b8fd..420241a 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,67 +12,53 @@
 . lib/test
 
 aux prepare_pvs 5 10
-# FIXME - test fails with extent size < 512k
-vgcreate -c n -s 512k $vg $(cat DEVICES)
+# proper DEVRANGE needs to be set according to extent size
+DEVRANGE="0-32"
+vgcreate -s 32k $vg $(cat DEVICES)
 
 # convert from linear to 2-way mirror
-lvcreate -l2 -n $lv1 $vg "$dev1"
+lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # convert from linear to 2-way mirror - with tags and volume_list (bz683270)
-lvcreate -l2 -n $lv1 $vg --addtag hello
+lvcreate -aey -l2 -n $lv1 $vg --addtag hello
 lvconvert -i1 -m+1 $vg/$lv1 \
     --config 'activation { volume_list = [ "@hello" ] }'
 lvremove -ff $vg
 
 # convert from 2-way to 3-way mirror - with tags and volume_list (bz683270)
-lvcreate -l2 -m1 -n $lv1 $vg --addtag hello
+lvcreate -aey -l2 -m1 -n $lv1 $vg --addtag hello
 lvconvert -i1 -m+1 $vg/$lv1 \
     --config 'activation { volume_list = [ "@hello" ] }'
 lvremove -ff $vg
 
 # convert from 2-way mirror to linear
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
 lvremove -ff $vg
 # and now try removing a specific leg (bz453643)
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m0 $vg/$lv1 "$dev2"
 check lv_on $vg $lv1 "$dev1"
 lvremove -ff $vg
 
 # convert from disklog to corelog, active
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, active
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
-lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
-check mirror $vg $lv1 "$dev3"
-lvremove -ff $vg
-
-# bz192865: lvconvert log of an inactive mirror lv
-# convert from disklog to corelog, inactive
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
-lvchange -an $vg/$lv1
-echo y | lvconvert -f --mirrorlog core $vg/$lv1
-check mirror $vg $lv1 core
-lvremove -ff $vg
-
-# convert from corelog to disklog, inactive
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
-lvchange -an $vg/$lv1
+lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # convert linear to 2-way mirror with 1 PV
-lvcreate -l2 -n $lv1 $vg "$dev1"
+lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 "$dev1"
 lvremove -ff $vg
 
@@ -80,7 +66,7 @@ lvremove -ff $vg
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:0"
+lvcreate -aey -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 # FIXME:
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
@@ -99,7 +85,7 @@ lvremove -ff $vg
 
 # No parallel lvconverts on a single LV please
 
-lvcreate -l5 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l5 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
@@ -116,7 +102,7 @@ lvremove -ff $vg
 
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvconvert -m +1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
@@ -125,7 +111,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # remove 1 mirror from corelog'ed mirror; should retain 'core' log type
-lvcreate -l2 -m2 --corelog -n $lv1 $vg
+lvcreate -aey -l2 -m2 --corelog -n $lv1 $vg
 lvconvert -m -1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
@@ -144,17 +130,11 @@ lvremove -ff $vg
 #check mirror_legs $vg $lv1 4
 #lvremove -ff $vg
 
-# Linear to mirror with mirrored log using --alloc anywhere
-lvcreate -l2 -n $lv1 $vg "$dev1"
-lvconvert -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
-should check mirror $vg $lv1
-lvremove -ff $vg
-
 # convert inactive mirror and start polling
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
-lvchange -ay $vg/$lv1
+lvchange -aey $vg/$lv1
 lvconvert $vg/$lv1 # wait
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -164,7 +144,7 @@ lvremove -ff $vg
 # removal during conversion
 
 # "remove newly added mirror"
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
@@ -175,7 +155,7 @@ check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
 # "remove one of newly added mirrors"
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
@@ -186,7 +166,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original is still mirror)"
-lvcreate -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:0"
+lvcreate -aey -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
@@ -197,7 +177,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original becomes linear)"
-lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
@@ -210,21 +190,21 @@ lvremove -ff $vg
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-lvcreate -l`pvs --noheadings -ope_count "$dev1"` -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l$(pvs --noheadings -ope_count "$dev1") -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 aux wait_for_sync $vg $lv1
 lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
 
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
-lvcreate -l2 -m1 -n$lv1 --nosync $vg
+lvcreate -aey -l2 -m1 -n $lv1 --nosync $vg
 lvconvert -m0 $vg/$lv1
 lvconvert -m1 $vg/$lv1
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
 lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
-lvcreate -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
+lvcreate -aey -l 8 -n $lv1 $vg "$dev1:0-3" "$dev2:0-3"
 lvconvert -m1 $vg/$lv1
 
 should check mirror $vg $lv1
@@ -232,7 +212,7 @@ check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
-lvcreate -l1 -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
@@ -243,10 +223,10 @@ lvremove -ff $vg
 # add mirror and disk log
 
 # "add 1 mirror and disk log"
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 
 # FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 "$dev4" "$dev3:0"
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 "$dev4" "$dev3:$DEVRANGE"
 
 check mirror $vg $lv1 "$dev3"
 check mirror_no_temporaries $vg $lv1
@@ -254,27 +234,61 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # simple mirrored stripe
-lvcreate -i2 -l10 -n $lv1 $vg
+lvcreate -aey -i2 -l10 -n $lv1 $vg
 lvconvert -m1 -i1 $vg/$lv1
 lvreduce -f -l1 $vg/$lv1
 lvextend -f -l10 $vg/$lv1
 lvremove -ff $vg/$lv1
 
 # extents must be divisible
-lvcreate -l15 -n $lv1 $vg
+lvcreate -aey -l15 -n $lv1 $vg
 not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
 
+test -e LOCAL_CLVMD && exit 0
+
+# FIXME - cases which needs to be fixed to work in cluster
+# Linear to mirror with mirrored log using --alloc anywhere
+lvcreate -aey -l2 -n $lv1 $vg "$dev1"
+lvconvert -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
+should check mirror $vg $lv1
+lvremove -ff $vg
+
 # Should not be able to add images to --nosync mirror
 # but should be able to after 'lvchange --resync'
-lvcreate -m 1 -l1 -n $lv1 $vg --nosync
+lvcreate -aey -m 1 -l1 -n $lv1 $vg --nosync
 not lvconvert -m +1 $vg/$lv1
-lvchange --resync -y $vg/$lv1
+lvchange -aey --resync -y $vg/$lv1
 lvconvert -m +1 $vg/$lv1
 lvremove -ff $vg
 
-lvcreate -m 1 --corelog -l1 -n $lv1 $vg --nosync
+lvcreate -aey -m 1 --corelog -l1 -n $lv1 $vg --nosync
 not lvconvert -m +1 $vg/$lv1
-lvchange --resync -y $vg/$lv1
+lvchange -aey --resync -y $vg/$lv1
 lvconvert -m +1 $vg/$lv1
 lvremove -ff $vg
+
+# FIXME: Cluster exclusive activation does not work here
+# unsure why  lib/metadata/mirror.c
+# has this code:
+#
+#       } else if (vg_is_clustered(vg)) {
+#                log_error("Unable to convert the log of an inactive "
+#                          "cluster mirror, %s", lv->name);
+#                return 0;
+# disabling this in the code passes this test
+
+# bz192865: lvconvert log of an inactive mirror lv
+# convert from disklog to corelog, inactive
+lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvchange -an $vg/$lv1
+lvconvert -y -f --mirrorlog core $vg/$lv1
+check mirror $vg $lv1 core
+lvremove -ff $vg
+
+# convert from corelog to disklog, inactive
+lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvchange -an $vg/$lv1
+lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
+check mirror $vg $lv1 "$dev3"
+lvremove -ff $vg
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 974628a..c85c1cf 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -19,74 +19,76 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 # multiple failures, full replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
 aux disable_dev "$dev1" "$dev2"
-echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 lvs -a -o +devices $vg | not grep unknown
 not grep "WARNING: Failed" 3way.out
 vgreduce --removemissing $vg
 check mirror $vg 3way
 aux enable_dev "$dev1" "$dev2"
-
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-
-# 2-way, mirrored log
-# Double log failure, full replace
-lvcreate --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
-    "$dev1" "$dev2" "$dev3":0 "$dev4":0
-aux disable_dev "$dev3" "$dev4"
-echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
-lvs -a -o +devices $vg | not grep unknown
-not grep "WARNING: Failed" 2way.out
-vgreduce --removemissing $vg
-check mirror $vg 2way
-aux enable_dev "$dev3" "$dev4"
-
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-
-# 3-way, mirrored log
-# Single log failure, replace
-lvcreate --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
-    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
-aux disable_dev "$dev4"
-echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
-lvs -a -o +devices $vg | not grep unknown
-not grep "WARNING: Failed" 3way.out
-vgreduce --removemissing $vg
-check mirror $vg 3way
-aux enable_dev "$dev4"
-
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+vgremove -ff $vg
 
 # 3-way, disk log
 # multiple failures, partial replace
-lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+lvcreate -aey --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
 aux disable_dev "$dev1" "$dev2"
-echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
+lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
 lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 3way
 aux enable_dev "$dev1" "$dev2"
-lvchange -a n $vg/3way
+vgremove -ff $vg
 
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
-
-lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
+vgcreate $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev1"
-echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
+lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
 lvs -a -o +devices $vg | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 2way
 aux enable_dev "$dev1" "$dev2"
-lvchange -a n $vg/2way
-
-vgremove -ff $vg; vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgremove -ff $vg
 
 # Test repair of inactive mirror with log failure
-#  Replacement should fail, but covert should succeed (switch to corelog)
-lvcreate -m 2 --ig -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+#  Replacement should fail, but convert should succeed (switch to corelog)
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -aey -m 2 --ig -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
-echo 'y' | lvconvert -y --repair $vg/mirror2
+lvconvert -y --repair $vg/mirror2
 check mirror $vg mirror2
 vgs $vg
+vgremove -ff $vg
+
+# FIXME  - exclusive activation for mirrors should work here
+test -e LOCAL_CLVMD && exit 0
+
+# 2-way, mirrored log
+# Double log failure, full replace
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+lvcreate -aey --mirrorlog mirrored -m 1 --ig -L 1 -n 2way $vg \
+    "$dev1" "$dev2" "$dev3":0 "$dev4":0
+aux disable_dev "$dev3" "$dev4"
+lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
+lvs -a -o +devices $vg | not grep unknown
+not grep "WARNING: Failed" 2way.out
+vgreduce --removemissing $vg
+check mirror $vg 2way
+aux enable_dev "$dev3" "$dev4"
+vgremove -ff $vg
+
+# 3-way, mirrored log
+# Single log failure, replace
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
+lvcreate -aey --mirrorlog mirrored -m 2 --ig -L 1 -n 3way $vg \
+    "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
+aux disable_dev "$dev4"
+lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
+lvs -a -o +devices $vg | not grep unknown
+not grep "WARNING: Failed" 3way.out
+vgreduce --removemissing $vg
+check mirror $vg 3way
+aux enable_dev "$dev4"
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 6bc646a..57ba8a5 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -14,7 +14,7 @@
 recreate_vg_()
 {
 	vgremove -ff $vg
-	vgcreate -c n $vg $(cat DEVICES)
+	vgcreate $vg "$@" $(cat DEVICES)
 }
 
 aux lvmconf 'allocation/maximise_cling = 0'
@@ -24,7 +24,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 4-way, disk log => 2-way, disk log
 aux prepare_vg 8
-lvcreate -m 3 --ig -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey -m 3 --ig -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -34,7 +34,7 @@ check mirror $vg 4way "$dev5"
 
 # 3-way, disk log => linear
 recreate_vg_
-lvcreate -m 2 --ig -L 1 -n 3way $vg
+lvcreate -aey -m 2 --ig -L 1 -n 3way $vg
 aux disable_dev "$dev1" "$dev2"
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
@@ -49,7 +49,7 @@ check linear $vg 3way
 
 # 3-way, disk log => 3-way, core log
 recreate_vg_
-lvcreate -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey -m 2 --ig -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 aux disable_dev "$dev4"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
@@ -60,8 +60,8 @@ vgreduce --removemissing $vg
 aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
-recreate_vg_
-lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
+recreate_vg_ -c n
+lvcreate -aey -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4" "$dev5"
 echo n | lvconvert --repair $vg/3way
@@ -74,7 +74,7 @@ aux enable_dev "$dev4" "$dev5"
 
 # 2-way, disk log => 2-way, core log
 recreate_vg_
-lvcreate -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
+lvcreate -aey -m 1 --ig -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
 aux disable_dev "$dev3"
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
@@ -88,11 +88,11 @@ aux enable_dev "$dev3"
 recreate_vg_
 vgreduce $vg "$dev4"
 
-lvcreate -m 1 --ig -L 1 -n mirror $vg
+lvcreate -aey -m 1 --ig -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 vgextend $vg "$dev4"
 aux disable_dev "$dev1"
-lvchange --partial -a y $vg/mirror
+lvchange --partial -aey $vg/mirror
 
 not vgreduce -v --removemissing $vg
 lvconvert -y --repair $vg/mirror
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 8768bb3..b1cb274 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -13,6 +13,7 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_vg 5
@@ -29,7 +30,7 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
-vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
 
 # bz837927 START
 
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index c9d4a2a..e4dadbd 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -13,6 +13,7 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
 aux target_at_least dm-raid 1 3 0 || skip
 
 aux prepare_vg 5
@@ -26,7 +27,7 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 aux lvmconf 'devices/filter = [ "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
 
 pvcreate $DM_DEV_DIR/$vg/$lv[12345]
-vgcreate -c n $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
 
 #
 # Create large RAID LVs
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 0ef3138..fa02cd5 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -21,15 +21,18 @@ cleanup_lvs() {
 
 aux prepare_pvs 2
 aux pvcreate --metadatacopies 0 "$dev1"
-aux vgcreate -c n $vg $(cat DEVICES)
+aux vgcreate $vg $(cat DEVICES)
 
 # ---
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
-lvcreate -n$lv1 -l4 $vg "$dev1"
+lvcreate -aey -n$lv1 -l4 $vg "$dev1"
 lvcreate -n$lv2 -l4 -s $vg/$lv1
 lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
 cleanup_lvs
 
+# Skip the rest for cluster
+test -e LOCAL_CLVMD && exit 0
+
 # ---
 # Create mirror on two devices with mirrored log using --alloc anywhere
 lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 806fff1..6daf794 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -18,7 +18,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 # not required, just testing
 aux pvcreate --metadatacopies 0 "$dev1"
 
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 pvchange --addtag fast $(cat DEVICES)
 
 # 3 stripes with 3 PVs (selected by tag, @fast) is fine
@@ -31,18 +31,18 @@ not lvcreate -l4 -i4 $vg @fast
 not lvcreate -l2 -i2 $vg $DM_DEV_DIR/mapper/pv1
 
 # lvcreate mirror
-lvcreate -l1 -m1 $vg @fast
+lvcreate -aey -l1 -m1 $vg @fast
 
 # lvcreate mirror w/corelog
-lvcreate -l1 -m2 --corelog $vg @fast
+lvcreate -aey -l1 -m2 --corelog $vg @fast
 
 # lvcreate mirror w/no free PVs
-not lvcreate -l1 -m2 $vg @fast
+not lvcreate -aey -l1 -m2 $vg @fast
 
 # lvcreate mirror (corelog, w/no free PVs)
-not lvcreate -l1 -m3 --corelog $vg @fast
+not lvcreate -aey -l1 -m3 --corelog $vg @fast
 
 # lvcreate mirror with a single PV arg
-not lvcreate -l1 -m1 --corelog $vg "$dev1"
+not lvcreate -aey -l1 -m1 --corelog $vg "$dev1"
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 05c7428..195e4ab 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -11,13 +11,15 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
+
 ########################################################
 # MAIN
 ########################################################
 aux target_at_least dm-raid 1 1 0 || skip
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
-vgcreate -c n -s 512k $vg $(cat DEVICES)
+vgcreate -s 512k $vg $(cat DEVICES)
 
 ###########################################
 # Create, wait for sync, remove tests
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index 63d086f..e9a6ebe 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -11,13 +11,15 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
+
 ########################################################
 # MAIN
 ########################################################
 aux target_at_least dm-raid 1 3 0 || skip
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
-vgcreate -c n -s 512k $vg $(cat DEVICES)
+vgcreate -s 512k $vg $(cat DEVICES)
 
 #
 # Create RAID10:
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index 88ac114..5efc412 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -19,7 +19,7 @@ for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2"
         pvcreate --metadatacopies 0 "$dev3"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
+		vgcreate $vg "$dev1" "$dev2" "$dev3"
 	fi
 	pvchange --metadataignore y "$dev1"
 	check pv_field "$dev1" pv_mda_count $mdacp
@@ -68,7 +68,7 @@ for mdacp in 1 2; do
 	check pv_field "$dev4" pv_mda_used_count $mdacp
 	check pv_field "$dev5" pv_mda_used_count $mdacp
 	pvcreate --metadatacopies 0 "$dev3"
-	vgcreate -c n $vg "$dev1" "$dev2" "$dev3"
+	vgcreate $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies unmanaged
 	echo ensure both --vgmetadatacopies and --metadatacopies accepted
 	vgchange --metadatacopies $(($mdacp * 1)) $vg
@@ -91,22 +91,22 @@ for mdacp in 1 2; do
 	pvchange --metadataignore y "$dev1" "$dev2"
 	check pv_field "$dev1" pv_mda_count $mdacp
 	check pv_field "$dev2" pv_mda_used_count 0
-	vgcreate -c n $vg "$dev1" "$dev2"
+	vgcreate $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds with a specific number of metadata copies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) $vg "$dev1" "$dev2"
+	vgcreate --vgmetadatacopies $(($mdacp * 2)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 2))
 	vgremove -f $vg
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2"
+	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	vgremove -f $vg
 	echo vgcreate succeeds with a larger value than total metadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2"
+	vgcreate --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	vgremove -f $vg
 	echo vgcreate succeeds with --vgmetadatacopies unmanaged
-	vgcreate -c n --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
+	vgcreate --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	pvunignore_ "$dev1"
@@ -114,7 +114,7 @@ for mdacp in 1 2; do
 	pvunignore_ "$dev4"
 	pvunignore_ "$dev5"
 	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
-	vgcreate -c n --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
+	vgcreate --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies 1
 	check vg_field $vg vg_mda_count $(($mdacp * 4))
 	check vg_field $vg vg_mda_used_count 1
@@ -131,7 +131,7 @@ for mdacp in 1 2; do
 	vgchange --vgmetadatacopies 0 $vg
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	vgcreate -c n --vgmetadatacopies 0 $vg "$dev1" "$dev2" "$dev4" "$dev5"
+	vgcreate --vgmetadatacopies 0 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 done
@@ -141,7 +141,7 @@ for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
 	pvcreate --metadatacopies 0 "$dev3"
 	echo Set a large value of vgmetadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2" "$dev3"
+	vgcreate --vgmetadatacopies $(($mdacp * 5)) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Large value of vgetadatacopies should automatically un-ignore mdas
@@ -152,7 +152,7 @@ for mdacp in 1 2; do
 	check pv_field "$dev5" pv_mda_used_count $mdacp
 	vgremove -f $vg
 	echo Set a small value of vgmetadatacopies
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2" "$dev3"
+	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Small value of vgetadatacopies should leave mdas as ignored
@@ -185,8 +185,8 @@ done
 echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate -c n --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 "$dev4" "$dev5"
+	vgcreate --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
@@ -206,7 +206,7 @@ done
 echo Test combination of --vgmetadatacopies and pvchange --metadataignore
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg1 "$dev1" "$dev2"
+	vgcreate --vgmetadatacopies $(($mdacp * 1)) $vg1 "$dev1" "$dev2"
 	check vg_field $vg1 vg_mda_copies $(($mdacp * 1))
 	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
 	pvignore_ "$dev3"
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index a9f8640..5109bf3 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -19,7 +19,7 @@ pvcreate --metadatacopies 0 "$dev3"
 pvcreate "$dev4"
 pvcreate --metadatacopies 0 "$dev5"
 
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
 pvchange -x n "$dev1"
@@ -33,11 +33,11 @@ vgremove -f $vg
 for mdacp in 1 0; do
 	pvcreate --metadatacopies $mdacp $(cat DEVICES)
 	pvcreate "$dev1"
-	vgcreate -c n $vg $(cat DEVICES)
+	vgcreate $vg $(cat DEVICES)
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
-	lvcreate -n $lv2 -m2 -l 2  $vg
+	lvcreate -aey -n $lv2 -m2 -l 2  $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
-	vgchange -ay $vg
+	vgchange -aey $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
 	vgremove -f $vg
 done
@@ -46,7 +46,7 @@ not grep "Cached VG .* incorrect PV list" out0
 # some M1 metadata tests
 pvcreate -M1 "$dev1" "$dev2" "$dev3"
 pv3_uuid=$(get pv_field "$dev3" pv_uuid)
-vgcreate -M1 -c n $vg "$dev1" "$dev2" "$dev3"
+vgcreate -M1 $vg "$dev1" "$dev2" "$dev3"
 pvchange --uuid "$dev1"
 
 # verify pe_start of all M1 PVs
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 2cf759e..4fc91c7 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -15,21 +15,21 @@
 aux prepare_devs 4
 pvcreate "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3" "$dev4"
-vgcreate -c n $vg "$dev1" "$dev2" "$dev3" "$dev4"
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 lvcreate -l1 -n linear1 $vg "$dev1"
 lvcreate -l1 -n linear2 $vg "$dev2"
 lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 
-lvcreate -l1 -n origin1 $vg "$dev1"
+lvcreate -aey -l1 -n origin1 $vg "$dev1"
 lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
-lvcreate -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -aey -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
 aux disable_dev "$dev1"
-not vgchange -a y $vg
+not vgchange -aey $vg
 not vgck $vg
 
 check inactive $vg linear1
@@ -43,7 +43,7 @@ check inactive $vg mirror123
 vgchange -a n $vg
 aux enable_dev "$dev1"
 aux disable_dev "$dev2"
-not vgchange -a y $vg
+not vgchange -aey $vg
 not vgck $vg
 
 check active $vg linear1
@@ -57,7 +57,7 @@ check inactive $vg mirror123
 vgchange -a n $vg
 aux enable_dev "$dev2"
 aux disable_dev "$dev3"
-not vgchange -a y $vg
+not vgchange -aey $vg
 not vgck $vg
 
 check active $vg origin1
@@ -71,7 +71,7 @@ check active $vg mirror12
 vgchange -a n $vg
 aux enable_dev "$dev3"
 aux disable_dev "$dev4"
-vgchange -a y $vg
+vgchange -aey $vg
 not vgck $vg
 
 check active $vg origin1
diff --git a/test/shell/pv-duplicate.sh b/test/shell/pv-duplicate.sh
index 6a22cd1..6b9f309 100644
--- a/test/shell/pv-duplicate.sh
+++ b/test/shell/pv-duplicate.sh
@@ -15,7 +15,7 @@
 
 aux prepare_devs 3
 
-vgcreate -c n --metadatasize 128k $vg1 "$dev1"
+vgcreate --metadatasize 128k $vg1 "$dev1"
 
 # copy mda
 dd if="$dev1" of="$dev2" bs=256K count=1
diff --git a/test/shell/pvcreate-metadata0.sh b/test/shell/pvcreate-metadata0.sh
index 9154e75..01cb6be 100644
--- a/test/shell/pvcreate-metadata0.sh
+++ b/test/shell/pvcreate-metadata0.sh
@@ -24,9 +24,7 @@ pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
 
 # "check lv snapshot"
-vgcreate -c n $vg "$dev1" "$dev2"
-lvcreate -n $lv -l 60%FREE $vg
+vgcreate $vg "$dev1" "$dev2"
+lvcreate -aey -n $lv -l 60%FREE $vg
 lvcreate -s -n $lv2 -l 10%FREE $vg/$lv
-pvdisplay
-lvdisplay
 vgremove -f $vg
diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 148802f..c78e4bd 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -173,7 +173,7 @@ for ignore in y n; do
 	fi
 	echo "vgcreate has proper vg_mda_count and vg_mda_used_count"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate -c n $vg "$dev1" "$dev2"
+		vgcreate $vg "$dev1" "$dev2"
 		check vg_field $vg vg_mda_count "$(($mdacp * 2))"
 		if [ $ignore = y ]; then
 			check vg_field $vg vg_mda_used_count "1"
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index c6d724b..aa71215 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -23,7 +23,7 @@ pvs | not grep "$dev2"
 pvcreate  --metadatacopies 0 "$dev2"
 
 # check pvremove refuses to remove pv in a vg
-vgcreate -c n $vg "$dev1" "$dev2"
+vgcreate $vg "$dev1" "$dev2"
 not pvremove "$dev2" "$dev3"
 
 for mdacp in 0 1 2; do
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 6c35fc3..2bf87a1 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -14,15 +14,15 @@
 aux prepare_pvs 4
 
 # vgcreate with --addtag
-vgcreate -c n --addtag firstvg $vg1 "$dev1" "$dev2"
-vgcreate -c n --addtag secondvg $vg2 "$dev3" "$dev4"
+vgcreate --addtag firstvg $vg1 "$dev1" "$dev2"
+vgcreate --addtag secondvg $vg2 "$dev3" "$dev4"
 check vg_field $vg1 tags "firstvg"
 check vg_field $vg2 tags "secondvg"
 vgremove -f $vg1 $vg2
 
 # vgchange with --addtag and --deltag
-vgcreate -c n $vg1 "$dev1" "$dev2"
-vgcreate -c n $vg2 "$dev3" "$dev4"
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
 vgchange --addtag firstvgtag1 $vg1
 # adding a tag multiple times is not an error
 vgchange --addtag firstvgtag2 $vg1
@@ -41,7 +41,7 @@ vgchange --deltag firstvgtag1 $vg2
 vgremove -f $vg1 $vg2
 
 # lvcreate with --addtag
-vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate --addtag firstlvtag1 -l 4 -n $lv1 $vg1
 lvcreate --addtag secondlvtag1 -l 4 -n $lv2 $vg1
 check lv_field @firstlvtag1 tags "firstlvtag1"
@@ -51,7 +51,7 @@ not check lv_field $vg1/$lv1 tags "secondlvtag1"
 vgremove -f $vg1
 
 # lvchange with --addtag and --deltag
-vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv2 $vg1
 lvchange --addtag firstlvtag1 $vg1/$lv1
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index df73c6a..4fa73be 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -38,11 +38,11 @@ lvdev_() {
 }
 
 test_snapshot_mount() {
-    lvcreate -L 16M -n $lv1 $vg "$dev1"
+    lvcreate -aey -L4M -n $lv1 $vg "$dev1"
     mkfs.ext3 $(lvdev_ $vg $lv1)
     mkdir test_mnt
     mount "$(lvdev_ $vg $lv1)" test_mnt
-    lvcreate -L 16M -n $lv2 -s $vg/$lv1
+    lvcreate -L4M -n $lv2 -s $vg/$lv1
     umount test_mnt
     # mount the origin
     mount "$(lvdev_ $vg $lv1)" test_mnt
@@ -52,7 +52,6 @@ test_snapshot_mount() {
     umount test_mnt
     rm -r test_mnt
     vgchange -an $vg
-    lvremove -f $vg/$lv2
     lvremove -f $vg/$lv1
 }
 
@@ -80,7 +79,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
 
@@ -95,7 +94,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
 
@@ -110,7 +109,7 @@ aux prepare_scsi_debug_dev $DEV_SIZE \
 check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $(cat DEVICES)
+vgcreate $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
 
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 413fef9..9da08ed 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -14,14 +14,14 @@
 aux prepare_dmeventd
 aux prepare_pvs 3
 
-vgcreate -c n -l 2 $vg $(cat DEVICES)
-lvcreate -n one -l 1 $vg
+vgcreate -l 2 $vg $(cat DEVICES)
+lvcreate -aey -n one -l 1 $vg
 lvcreate -n two -l 1 $vg
 not lvcreate -n three -l 1 $vg
 vgremove -ff $vg
 
-vgcreate -c n -l 3 $vg $(cat DEVICES)
-lvcreate -n one -l 1 $vg
+vgcreate -l 3 $vg $(cat DEVICES)
+lvcreate -aey -n one -l 1 $vg
 lvcreate -n snap -s -l 1 $vg/one
 lvcreate -n two -l 1 $vg
 not lvcreate -n three -l 1 $vg
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index d7a166c..67f07df 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -11,10 +11,11 @@
 
 . lib/test
 
+test -e LOCAL_CLVMD && skip
+
 which mkfs.ext3 || skip
 
 aux prepare_pvs 2 8
-test -e LOCAL_CLVMD && skip
 
 var_lock="$DM_DEV_DIR/$vg1/$lv1"
 # keep in sync with aux configured lockingdir
@@ -26,8 +27,8 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
-vgcreate -c n $vg1 "$dev1"
-vgcreate -c n $vg2 "$dev2"
+vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
 
 lvcreate -l 1 -n $lv2 $vg2
 vgchange -an $vg2
diff --git a/test/shell/vgcreate-usage.sh b/test/shell/vgcreate-usage.sh
index db80f0f..bf7d3b3 100644
--- a/test/shell/vgcreate-usage.sh
+++ b/test/shell/vgcreate-usage.sh
@@ -20,7 +20,7 @@ pvcreate --metadatacopies 0 "$dev3"
 vg=${PREFIX}vg
 
 #COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
-vgcreate -c n $vg --physicalextentsize 8.00m "$dev1" "$dev2"
+vgcreate $vg --physicalextentsize 8.00m "$dev1" "$dev2"
 check vg_field  $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
@@ -28,31 +28,31 @@ not vgremove $vg
 not vgck $vg
 
 #COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
-vgcreate -c n $vg --maxlogicalvolumes 128 "$dev1" "$dev2" 
+vgcreate $vg --maxlogicalvolumes 128 "$dev1" "$dev2"
 check vg_field $vg max_lv 128 
 vgremove $vg
 
 #COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
-vgcreate -c n $vg --maxphysicalvolumes 128 "$dev1" "$dev2"
+vgcreate $vg --maxphysicalvolumes 128 "$dev1" "$dev2"
 check vg_field $vg max_pv 128
 vgremove $vg
 
 #COMM 'vgcreate rejects a zero physical extent size'
-not vgcreate -c n --physicalextentsize 0 $vg "$dev1" "$dev2" 2>err
+not vgcreate --physicalextentsize 0 $vg "$dev1" "$dev2" 2>err
 grep "Physical extent size may not be zero" err
 
 #COMM 'vgcreate rejects "inherit" allocation policy'
-not vgcreate -c n --alloc inherit $vg "$dev1" "$dev2" 2>err
+not vgcreate --alloc inherit $vg "$dev1" "$dev2" 2>err
 grep "Volume Group allocation policy cannot inherit from anything" err
 
 #COMM 'vgcreate rejects vgname "."'
 vginvalid=.; 
-not vgcreate -c n $vginvalid "$dev1" "$dev2" 2>err
+not vgcreate $vginvalid "$dev1" "$dev2" 2>err
 grep "New volume group name \"$vginvalid\" is invalid" err
 
 #COMM 'vgcreate rejects vgname greater than 128 characters'
 vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
-not vgcreate -c n $vginvalid "$dev1" "$dev2" 2>err
+not vgcreate $vginvalid "$dev1" "$dev2" 2>err
 grep "New volume group name \"$vginvalid\" is invalid" err
 
 #COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
@@ -61,47 +61,49 @@ grep "New volume group name \"$vginvalid\" is invalid" err
 #grep "New volume group name \"$vg\" is invalid\$" err
 
 #COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
-vgcreate -c n $vg "$dev1" "$dev2"
-not vgcreate -c n $vg "$dev1" "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+not vgcreate $vg "$dev1" "$dev2"
 vgremove -ff $vg
 
 #COMM 'vgcreate rejects MaxLogicalVolumes > 255'
-not vgcreate -c n --metadatatype 1 --maxlogicalvolumes 1024 $vg "$dev1" "$dev2" 2>err
+not vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg "$dev1" "$dev2" 2>err
 grep "Number of volumes may not exceed 255" err
 
 #COMM "vgcreate fails when the only pv has --metadatacopies 0"
-not vgcreate -c n $vg "$dev3"
+not vgcreate $vg "$dev3"
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
-not vgcreate -c n --physicalextentsize 0k $vg "$dev1" "$dev2"
-vgcreate -c n --physicalextentsize 1k $vg "$dev1" "$dev2"
+not vgcreate --physicalextentsize 0k $vg "$dev1" "$dev2"
+vgcreate --physicalextentsize 1k $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 1.00k
 vgremove -ff $vg
-not vgcreate -c n --physicalextentsize 3K $vg "$dev1" "$dev2"
-not vgcreate -c n --physicalextentsize 1024t $vg "$dev1" "$dev2"
+not vgcreate --physicalextentsize 3K $vg "$dev1" "$dev2"
+not vgcreate --physicalextentsize 1024t $vg "$dev1" "$dev2"
 #not vgcreate --physicalextentsize 1T $vg "$dev1" "$dev2"
 # FIXME: vgcreate allows physicalextentsize larger than pv size!
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
-vgcreate -c n $vg "$dev1" "$dev2"
+vgcreate $vg "$dev1" "$dev2"
 check vg_field $vg vg_extent_size 4.00m
 check vg_field $vg max_lv 0
 check vg_field $vg max_pv 0
-check vg_field $vg vg_attr "wz--n-"
+ATTRS="wz--n-"
+test -e LOCAL_CLVMD && ATTRS="wz--nc"
+check vg_field $vg vg_attr $ATTRS
 vgremove -ff $vg
 
 # Implicit pvcreate tests, test pvcreate options on vgcreate
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
 pvremove "$dev1" "$dev2"
-vgcreate -c n --force --yes --zero y $vg "$dev1" "$dev2"
+vgcreate --force --yes --zero y $vg "$dev1" "$dev2"
 vgremove -f $vg
 pvremove -f "$dev1"
 
 for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
-    vgcreate -c n --labelsector $i $vg "$dev1"
+    vgcreate --labelsector $i $vg "$dev1"
     dd if="$dev1" bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgremove -f $vg
     pvremove -f "$dev1"
@@ -110,14 +112,14 @@ done
 # pvmetadatacopies
 for i in 1 2
 do
-    vgcreate -c n --pvmetadatacopies $i $vg "$dev1"
+    vgcreate --pvmetadatacopies $i $vg "$dev1"
     check pv_field "$dev1" pv_mda_count $i
     vgremove -f $vg
     pvremove -f "$dev1"
 done
-not vgcreate -c n --pvmetadatacopies 0 $vg "$dev1"
+not vgcreate --pvmetadatacopies 0 $vg "$dev1"
 pvcreate --metadatacopies 1 "$dev2"
-vgcreate -c n --pvmetadatacopies 0 $vg "$dev1" "$dev2"
+vgcreate --pvmetadatacopies 0 $vg "$dev1" "$dev2"
 check pv_field "$dev1" pv_mda_count 0
 check pv_field "$dev2" pv_mda_count 1
 vgremove -f $vg
@@ -125,7 +127,7 @@ pvremove -f "$dev1"
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
-vgcreate -c n --metadatasize 100k --dataalignment 100k $vg "$dev1"
+vgcreate --metadatasize 100k --dataalignment 100k $vg "$dev1"
 check pv_field "$dev1" pe_start 200.00k
 vgremove -f $vg
 pvremove -f "$dev1"
@@ -133,7 +135,7 @@ pvremove -f "$dev1"
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
 pv_align=1052160 # 1048576 + (7*512)
-vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
+vgcreate --metadatasize 128k --dataalignmentoffset 7s $vg "$dev1"
 check pv_field "$dev1" pe_start ${pv_align}B --units b
 vgremove -f $vg
 pvremove -f "$dev1"
@@ -141,23 +143,22 @@ pvremove -f "$dev1"
 # metadatatype
 for i in 1 2
 do
-    vgcreate -c n -M $i $vg "$dev1"
+    vgcreate -M $i $vg "$dev1"
     check vg_field $vg vg_fmt lvm$i
     vgremove -f $vg
     pvremove -f "$dev1"
 done
 
 # vgcreate fails if pv belongs to existing vg
-vgcreate -c n $vg1 "$dev1" "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
 not vgcreate $vg2 "$dev2"
 vgremove -f $vg1
 pvremove -f "$dev1" "$dev2"
 
 # all PVs exist in the VG after created
 pvcreate "$dev1"
-vgcreate -c n $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $vg1 "$dev1" "$dev2" "$dev3"
 check pv_field "$dev1" vg_name $vg1
 check pv_field "$dev2" vg_name $vg1
 check pv_field "$dev3" vg_name $vg1
 vgremove -f $vg1
-pvremove -f "$dev1" "$dev2" "$dev3"
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 60c833a..4b66f96 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -13,7 +13,7 @@
 
 aux prepare_devs 2
 
-vgcreate -c n --metadatasize 128k $vg1 "$dev1"
+vgcreate --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Clone the LUN
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index bdd5000..4303aff 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -16,8 +16,8 @@ test_description='Test vgmerge operation'
 aux prepare_pvs 4 64
 
 # 'vgmerge succeeds with single linear LV in source VG'
-vgcreate -c n $vg1 "$dev1" "$dev2"
-vgcreate -c n $vg2 "$dev3" "$dev4"
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
 lvcreate -l 4 -n $lv1 $vg1 "$dev1"
 vgchange -an $vg1
 check pvlv_counts $vg1 2 1 0
@@ -27,8 +27,8 @@ check pvlv_counts $vg2 4 1 0
 vgremove -f $vg2
 
 # 'vgmerge succeeds with single linear LV in source and destination VG'
-vgcreate -c n $vg1 "$dev1" "$dev2"
-vgcreate -c n $vg2 "$dev3" "$dev4"
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv2 $vg2
 vgchange -an $vg1
@@ -40,9 +40,9 @@ check pvlv_counts $vg2 4 2 0
 vgremove -f $vg2
 
 # 'vgmerge succeeds with linear LV + snapshots in source VG'
-vgcreate -c n $vg1 "$dev1" "$dev2"
-vgcreate -c n $vg2 "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 $vg1
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
+lvcreate -aey -l 16 -n $lv1 $vg1
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1
 vgchange -an $vg1
 check pvlv_counts $vg1 2 2 1
@@ -53,9 +53,9 @@ lvremove -f $vg2/$lv2
 vgremove -f $vg2
 
 # 'vgmerge succeeds with mirrored LV in source VG'
-vgcreate -c n $vg1 "$dev1" "$dev2" "$dev3"
-vgcreate -c n $vg2 "$dev4"
-lvcreate -l 4 -n $lv1 -m1 $vg1
+vgcreate $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $vg2 "$dev4"
+lvcreate -aey -l 4 -n $lv1 -m1 $vg1
 vgchange -an $vg1
 check pvlv_counts $vg1 3 1 0
 check pvlv_counts $vg2 1 0 0
@@ -65,8 +65,8 @@ lvremove -f $vg2/$lv1
 vgremove -f $vg2
 
 # 'vgmerge rejects LV name collision'
-vgcreate -c n $vg1 "$dev1" "$dev2"
-vgcreate -c n $vg2 "$dev3" "$dev4"
+vgcreate $vg1 "$dev1" "$dev2"
+vgcreate $vg2 "$dev3" "$dev4"
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv1 $vg2
 vgchange -an $vg1
diff --git a/test/shell/vgmerge-usage.sh b/test/shell/vgmerge-usage.sh
index 17779b5..ef613d7 100644
--- a/test/shell/vgmerge-usage.sh
+++ b/test/shell/vgmerge-usage.sh
@@ -21,8 +21,8 @@ vgcreate  $vg1 "$dev1" "$dev2"
 vgcreate  $vg2 "$dev3" "$dev4"
 vgmerge $vg1 $vg2
 vgremove $vg1
-vgcreate -c n $vg2 "$dev1" "$dev2"
-vgcreate -c n $vg1 "$dev3" "$dev4"
+vgcreate $vg2 "$dev1" "$dev2"
+vgcreate $vg1 "$dev3" "$dev4"
 vgmerge $vg2 $vg1
 vgremove $vg2
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 9a55d3c..350e169 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -19,18 +19,18 @@ do
     pvcreate -M$mdatype "$dev1" "$dev2"
 
     # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
-    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
     vgreduce $vg1 "$dev1"
     check pv_field "$dev2" vg_name $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
-    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
     not vgreduce --all $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv
-    vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2"
+    vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
     not vgreduce $vg1 "$dev1" "$dev2"
     vgremove -f $vg1
 
@@ -44,14 +44,14 @@ pvcreate -M$mdatype "$dev1" "$dev2"
 pvcreate --metadatacopies 0 -M$mdatype "$dev3" "$dev4"
 
 # (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
-vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev3"
+vgcreate -M$mdatype $vg1 "$dev1" "$dev3"
 not vgreduce $vg1 "$dev1"
 vgremove -f $vg1
 
 #COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
-vgcreate -c n -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
-lvcreate -n $lv1 -m1 -l 4 $vg1
+vgcreate -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -n $lv1 -m1 -l 4 $vg1
 lvcreate -n $lv2  -l 4 $vg1 "$dev2"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
 vgchange -an $vg1
@@ -68,9 +68,9 @@ not vgs $vg1 # just double-check it's really gone
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -c n -M$mdatype $vg1 $(cat DEVICES)
+vgcreate -M$mdatype $vg1 $(cat DEVICES)
 lvcreate -n $lv2 -l 4 $vg1
-lvcreate -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
 pvs --segments -o +lv_name $(cat DEVICES) # for record only
 # (lvm$mdatype) setup: damage one pv
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index c9cc04a..c93a1fc 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -18,7 +18,7 @@ COMM() {
 }
 
 create_vg_() {
-	vgcreate -c n -s 64k "$@"
+	vgcreate -s 64k "$@"
 }
 
 aux prepare_pvs 5 10
@@ -79,7 +79,7 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev4"
 
-		lvcreate -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		lvcreate -aey -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		vgchange -an $vg1
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
@@ -96,10 +96,10 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 # FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
 COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
-		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-		test $i = existing && create_vg_ $vg2 "$dev5"
+		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+		test $i = existing && create_vg_ -c n $vg2 "$dev5"
 
-		lvcreate -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
+		lvcreate -aey -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
 		    "$dev1" "$dev2" "$dev3" "$dev4"
 
 		vgchange -an $vg1
@@ -121,7 +121,7 @@ COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"
 		test $i = existing && create_vg_ $vg2 "$dev3" "$dev4"
 
-		lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+		lvcreate -aey -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
 		vgchange -an $vg1
 		if [ $j = PV ]; then
@@ -142,7 +142,7 @@ COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j a
 		create_vg_ $vg1 "$dev1" "$dev2"
 		test $i = existing && create_vg_ $vg2 "$dev3"
 
-		lvcreate -l 64 -i 2 -n $lv1 $vg1
+		lvcreate -aey -l 64 -i 2 -n $lv1 $vg1
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
 		vgextend $vg1 "$dev4"
 		lvcreate -l 64 -n $lv3 $vg1 "$dev4"
@@ -167,7 +167,7 @@ COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev5"
 
-		lvcreate -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		lvcreate -aey -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		vgextend $vg1 "$dev4"
 		lvcreate -l 64 -n $lv2 $vg1 "$dev4"
 		vgchange -an $vg1
@@ -203,7 +203,7 @@ vgremove -f $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -aey -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 "$dev3"
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 "$dev4"
 check pvlv_counts $vg1 4 3 2
@@ -215,7 +215,7 @@ vgremove -f $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -aey -l 16 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 "$dev3"
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 "$dev4"
 check pvlv_counts $vg1 4 3 2
@@ -227,7 +227,7 @@ vgremove -f $vg1
 
 COMM "vgsplit fails splitting one mirror LV, only one PV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
 check pvlv_counts $vg1 4 1 0
 vgchange -an $vg1
 not vgsplit $vg1 $vg2 "$dev2"
@@ -235,7 +235,7 @@ vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
 check pvlv_counts $vg1 4 2 0
 vgchange -an $vg1
@@ -247,7 +247,7 @@ vgremove -f $vg1
 #
 COMM "vgsplit fails, active mirror involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0
@@ -257,7 +257,7 @@ vgremove -f $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0
@@ -268,7 +268,7 @@ vgremove -f $vg1 $vg2
 
 COMM "vgsplit fails, active snapshot involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -aey -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1
 lvcreate -l 64 -i 2 -n $lv3 $vg1 "$dev3" "$dev4"
 lvchange -an $vg1/$lv3
@@ -280,7 +280,7 @@ vgremove -f $vg1
 
 COMM "vgsplit succeeds, active snapshot not involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
-lvcreate -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
+lvcreate -aey -l 64 -i 2 -n $lv1 $vg1 "$dev1" "$dev2"
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1
 vgextend $vg1 "$dev4"
 lvcreate -l 64 -n $lv3 $vg1 "$dev4"


