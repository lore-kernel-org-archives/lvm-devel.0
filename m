From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Nov 2018 09:31:35 -0500
Subject: master - tests: add wait loop
Message-ID: <201811121431.wACEVZLq029183@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=517332e78ddf0ea1ed5735925b1047cf5cf4f8f8
Commit:        517332e78ddf0ea1ed5735925b1047cf5cf4f8f8
Parent:        836dc9876b58ae275b87cedebd11991639cbd019
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 12 15:28:45 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 12 15:30:40 2018 +0100

tests: add wait loop

Add a little wait loop - since lvconvert started background process
and we need to wait till this bg task initiate its work -
adding ~1s loop should give reasonable enough time to start mirroring.
---
 test/shell/mirror-names.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 54d42e1..6d46180 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -112,6 +112,12 @@ check_and_cleanup_lvs_
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
 # Use large enough polling interval so mirror is keeping mimagetmp
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
+for i in $(seq 1 10) ; do
+	# check if background process already started
+	# this is recognized by presence of LV1_mimage_2
+	check lvl $vg/${lv1}_mimage_2 && break
+	sleep .1
+done
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test "$convlv" = "${lv1}_mimagetmp_2"
 lv_devices_ $vg/$lv1 $convlv ${lv1}_mimage_2


