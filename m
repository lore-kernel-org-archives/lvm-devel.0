From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Mar 2018 07:09:52 -0400
Subject: master - tests: update no tool test
Message-ID: <201803191109.w2JB9q0l016337@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c02cc9e8ffba777a92d798ca08c60e73dd2c109
Commit:        8c02cc9e8ffba777a92d798ca08c60e73dd2c109
Parent:        4e0c0417ce1af29ae5253bca7f1277e13e3c3ee6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 19 10:26:50 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 19 12:08:04 2018 +0100

tests: update no tool test

Correct testing with format 1 and mq policy.

Add testing of 'smq'

Fix testing with clvmd - where logged message is part of clvmd log
and we can only check command status.
---
 test/shell/lvcreate-cache-no-tools.sh |  121 ++++++++++++++++++++++-----------
 1 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index 72359e5..c38ecfd 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -17,65 +17,104 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+if test -e LOCAL_CLVMD ; then
+# In cluster, the error from activation is logged in clvmd
+# so we can only check resulting state of activation
+	GREP=echo
+else
+	GREP=grep
+fi
+
+make_fake_() {
+	cat <<- EOF >fake-tool.sh
+#!/bin/sh
+echo "$1"
+exit 1
+EOF
+	chmod +x fake-tool.sh
+}
+
+check_change_() {
+	lvchange -an $vg |& tee out
+	"$GREP" "$1" out
+
+	lvchange -ay $vg |& tee out
+	"$GREP" "$1" out
+}
+
+# Integrity check fails, but deactivation is OK
+check_change_failed_() {
+	lvchange -an $vg |& tee out
+	"$GREP" "failed" out
+
+	# Activation must fail
+	fail lvchange -ay $vg |& tee out
+	"$GREP" "failed" out
+
+	cat <<- EOF >fake-tool.sh
+#!/bin/sh
+exit
+EOF
+	chmod +x fake-tool.sh
+	# Activate without any check
+	lvchange -ay $vg
+}
+
+
 aux have_cache 1 3 0 || skip
 
 # FIXME: parallel cache metadata allocator is crashing when used value 8000!
 aux prepare_vg 5 80000
 
-aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]' \
-	    'global/cache_check_executable = "./fake-tool.sh"'
-
+aux lvmconf 'global/cache_check_executable = "./fake-tool.sh"'
 rm -f fake-tool.sh
 
-lvcreate -l1 -n $lv1 $vg
-lvcreate -H -l2 $vg/$lv1
+# On cache target that supports  V2
+if aux have_cache 1 10 0 ; then
 
-lvchange -an $vg |& tee out
-grep "Check is skipped" out
+lvcreate -aey -l1 -n $lv1 $vg
+lvcreate -H -l2 $vg/$lv1
 
-lvchange -ay $vg
-grep "Check is skipped" out
+check_change_ "Check is skipped"
+vgcfgbackup -f /dev/shm/back
 
 # prepare fake version of cache_check tool that reports old version
-cat <<- EOF >fake-tool.sh
-#!/bin/sh
-echo "0.1.0"
-exit 1
-EOF
-chmod +x fake-tool.sh
+make_fake_ "0.1.0"
+check_change_ "upgrade"
 
-lvchange -an $vg |& tee out
-grep "upgrade" out
+# prepare fake version of cache_check tool that reports garbage
+make_fake_ "garbage"
+check_change_ "parse"
 
-lvchange -ay $vg
-grep "upgrade" out
+# prepare fake version of cache_check tool with high version
+make_fake_ "99.0.0"
+check_change_failed_
 
-# prepare fake version of cache_check tool that reports garbage
-cat <<- EOF >fake-tool.sh
-#!/bin/sh
-echo "garbage"
-exit 1
-EOF
-chmod +x fake-tool.sh
+lvremove -f $vg
+
+fi
 
-lvchange -an $vg |& tee out
-grep "parse" out
 
-lvchange -ay $vg
-grep "parse" out
+# On older cache target that supports only V1 format
+aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
+rm -f fake-tool.sh
+
+lvcreate -aey -l1 -n $lv1 $vg
+lvcreate -H -l2 $vg/$lv1
+
+check_change_ "Check is skipped"
+
+# prepare fake version of cache_check tool that reports old version
+make_fake_ "0.1.0"
+check_change_failed_
+
+# prepare fake version of cache_check tool that reports garbage
+make_fake_ "garbage"
+check_change_failed_
 
 # prepare fake version of cache_check tool with high version
-cat <<- EOF >fake-tool.sh
-#!/bin/sh
-echo "9.0.0"
-exit 1
-EOF
-chmod +x fake-tool.sh
+make_fake_ "99.0.0"
+check_change_failed_
 
-# Integrity check fails, but deactivation is OK
-lvchange -an $vg |& tee out
-grep "failed" out
-# Activation must fail
-fail lvchange -ay $vg
 
 vgremove -ff $vg


