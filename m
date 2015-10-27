From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Oct 2015 15:03:57 +0000 (UTC)
Subject: master - tests: avoid reading utils when skipping
Message-ID: <20151027150357.9D1E46092D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76cff10a734a7c1e26b3835ff967dac0b7e46bcb
Commit:        76cff10a734a7c1e26b3835ff967dac0b7e46bcb
Parent:        1af2ab10d02c2f02891d5047af563651fbe294bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 27 15:08:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 27 16:00:09 2015 +0100

tests: avoid reading utils when skipping

Save even more CPU/time and avoid reading utils, when skipping test.
---
 test/lib/inittest.sh |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index beb0210..6fde23a 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -9,6 +9,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
+initskip() {
+	test "$#" -eq 0 || echo "TEST SKIPPED: $@"
+	exit 200
+}
+
 # sanitize the environment
 LANG=C
 LC_ALL=C
@@ -20,19 +25,22 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
-unset CDPATH
-
-# grab some common utilities
-. lib/utils
-
 if test -n "$LVM_TEST_FLAVOUR"; then
 	. lib/flavour-$LVM_TEST_FLAVOUR
 fi
 
-test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && skip
-test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && skip
-test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && skip
+test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && initskip
+test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" -eq 3 && initskip
 
+test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && initskip
+test -n "$SKIP_WITH_LVMETAD" && test -n "$LVM_TEST_LVMETAD" && initskip
+
+test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && initskip
+
+unset CDPATH
+
+# grab some common utilities
+. lib/utils
 
 TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"


