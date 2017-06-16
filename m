From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Fri, 16 Jun 2017 11:16:32 -0400
Subject: master - test: New test file for validating kernel status during sync ops
Message-ID: <201706161516.v5GFGWGj011444@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=915d20d0e64e8bf7a91f01c21cb8c30428ddb1e1
Commit:        915d20d0e64e8bf7a91f01c21cb8c30428ddb1e1
Parent:        dd866a67f44ad44512388cf2e073511d88b9c19c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Jun 16 10:11:58 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Jun 16 10:16:07 2017 -0500

test: New test file for validating kernel status during sync ops

New tests to add checking for '100%' in-sync at start of "recover"
process (it shouldn't happen, but I've seen it before).  Also,
check status over the whole cycle of various sync processes ("resync"
and "recover").
---
 test/shell/lvconvert-raid-status-validation.sh |   95 +++++++++++++++++++++++-
 1 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index 0da0b7a..d705cc2 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -20,7 +20,7 @@ vgcreate -s 2m $vg $(cat DEVICES)
 ###########################################
 # Upconverted RAID1 should never have all 'a's in status output
 ###########################################
-aux delay_dev $dev2 0 100
+aux delay_dev $dev2 0 50
 lvcreate -aey -l 2 -n $lv1 $vg $dev1
 lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
 while ! check in_sync $vg $lv1; do
@@ -31,4 +31,97 @@ done
 aux enable_dev $dev2
 lvremove -ff $vg
 
+###########################################
+# Upconverted RAID1 should not be at 100% right after upconvert
+###########################################
+aux delay_dev $dev2 0 50
+lvcreate -aey -l 2 -n $lv1 $vg $dev1
+lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+b=( $(echo ${a[6]} | sed s:/:' ':) )
+[ ${b[0]} -ne ${b[1]} ]
+aux enable_dev $dev2
+lvremove -ff $vg
+
+###########################################
+# Catch anything suspicious with linear -> RAID1 upconvert
+###########################################
+aux delay_dev $dev2 0 50
+lvcreate -aey -l 2 -n $lv1 $vg $dev1
+lvconvert --type raid1 -y -m 1 $vg/$lv1 $dev2
+while true; do
+        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+	b=( $(echo ${a[6]} | sed s:/:' ':) )
+	if [ ${b[0]} -ne ${b[1]} ]; then
+		# If the sync operation ("recover" in this case) is not
+		# finished, then it better be as follows:
+		[ ${a[5]} == "Aa" ]
+		[ ${a[7]} == "recover" ]
+	else
+		# Tough to tell the INVALID case,
+		#   Before starting sync thread: "Aa X/X recover"
+		# from the valid case,
+		#   Just finished sync thread: "Aa X/X recover"
+		# We'll just put "should" for now
+		should [ ${a[5]} == "AA" ]
+		should [ ${a[7]} == "idle" ]
+		break
+	fi
+        sleep .1
+done
+aux enable_dev $dev2
+lvremove -ff $vg
+
+###########################################
+# Catch anything suspicious with RAID1 2-way -> 3-way upconvert
+###########################################
+aux delay_dev $dev3 0 50
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+lvconvert -y -m +1 $vg/$lv1 $dev3
+while true; do
+        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+	b=( $(echo ${a[6]} | sed s:/:' ':) )
+	if [ ${b[0]} -ne ${b[1]} ]; then
+		# If the sync operation ("recover" in this case) is not
+		# finished, then it better be as follows:
+		[ ${a[5]} == "AAa" ]
+		[ ${a[7]} == "recover" ]
+	else
+		# Tough to tell the INVALID case,
+		#   Before starting sync thread: "Aa X/X recover"
+		# from the valid case,
+		#   Just finished sync thread: "Aa X/X recover"
+		# We'll just put "should" for now
+		should [ ${a[5]} == "AAA" ]
+		should [ ${a[7]} == "idle" ]
+		break
+	fi
+        sleep .1
+done
+aux enable_dev $dev3
+lvremove -ff $vg
+
+###########################################
+# Catch anything suspicious with RAID1 initial resync
+###########################################
+aux delay_dev $dev2 0 50
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+while true; do
+        a=( $(dmsetup status $vg-$lv1) ) || die "Unable to get status of $vg/$lv1"
+	b=( $(echo ${a[6]} | sed s:/:' ':) )
+	if [ ${b[0]} -ne ${b[1]} ]; then
+		# If the sync operation ("resync" in this case) is not
+		# finished, then it better be as follows:
+		[ ${a[5]} == "aa" ]
+		[ ${a[7]} == "resync" ]
+	else
+		should [ ${a[5]} == "AA" ]
+		should [ ${a[7]} == "idle" ]
+		break
+	fi
+        sleep .1
+done
+aux enable_dev $dev2
+lvremove -ff $vg
+
 vgremove -ff $vg


