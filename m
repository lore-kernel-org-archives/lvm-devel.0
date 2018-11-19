From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:18:19 -0500
Subject: master - tests: skip portion of test for lvmpolld
Message-ID: <201811191218.wAJCIJGO012453@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7adcb5f6db7e7c1131b5dfb9114235a908292b1
Commit:        f7adcb5f6db7e7c1131b5dfb9114235a908292b1
Parent:        14f24c217586a4544b911b5ea90e8b627a8efd01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 18 21:38:56 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 18 22:03:50 2018 +0100

tests: skip portion of test for lvmpolld

lvmpolld ATM is not desingned to preserve interval checking
in the same way the 'lvconvert' tool is doing - so the passed
'-i 40' is not respected and lvmpolld autonomously checks
state of conversion and updates lvm2 metadata and dm tables
when needed.

So skip portion of test that relayed on this and preserve this logic
only for command line invocation and forking of polling process
where the interval of checking is under full control.
---
 test/shell/mirror-names.sh |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index 6d46180..1019bd3 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -112,6 +112,17 @@ check_and_cleanup_lvs_
 lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
 # Use large enough polling interval so mirror is keeping mimagetmp
 LVM_TEST_TAG="kill_me_$PREFIX" lvconvert -m+1 -i+40 -b $vg/$lv1
+
+#
+# TODO: lvmpolld is not 'preserving' -i  interval setting from
+# lvconvert initiating command - so there is not much to test
+# if the lvconvert is already finished at this point
+# and lvmpolld cleaned metadata and refreshed DM table
+#
+# It' unclear if this is undocumented feature of bug.
+#
+if test ! -f LOCAL_LVMPOLLD ; then
+
 for i in $(seq 1 10) ; do
 	# check if background process already started
 	# this is recognized by presence of LV1_mimage_2
@@ -139,6 +150,7 @@ convlv=$(lv_convert_lv_ $vg/$lv2)
 lv_devices_ $vg/$lv2 $convlv ${lv2}_mimage_2
 lv_devices_ $vg/$convlv ${lv2}_mimage_0 ${lv2}_mimage_1
 lv_mirror_log_ $vg/$convlv ${lv2}_mlog
+fi  # ! -f LOCAL_LVMPOLLD
 
 #COMM "cleanup"
 check_and_cleanup_lvs_


