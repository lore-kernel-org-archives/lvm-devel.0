From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 Sep 2020 15:31:12 +0000 (GMT)
Subject: master - tests: inittest supports SKIP_WITH_LOW_SPACE
Message-ID: <20200918153112.576303954C16@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=206620018eaac4b8b771cebfe9707022864bb53b
Commit:        206620018eaac4b8b771cebfe9707022864bb53b
Parent:        048e04e4176e62e5c9196c662497d18dc19483a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:25:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:30:31 2020 +0200

tests: inittest supports SKIP_WITH_LOW_SPACE

Test can set individually a higher value for required free space on
storage.

Note: it is not fully reliable since when 'brd' (ramdisk) device is used
this free space value is rather meanigul, but it might help
in case where a real filesystem is doing back-end for test devices.
---
 test/lib/inittest.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a6cefa861..44000b951 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -46,6 +46,7 @@ SKIP_WITH_CLVMD=${SKIP_WITH_CLVMD-}
 SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
 SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
 SKIP_ROOT_DM_CHECK=${SKIP_ROOT_DM_CHECK-}
+SKIP_WITH_LOW_SPACE=${SKIP_WITH_LOW_SPACE-50}
 
 test -n "$LVM_TEST_FLAVOUR" || { echo "NOTE: Empty flavour">&2; initskip; }
 test -f "lib/flavour-$LVM_TEST_FLAVOUR" || { echo "NOTE: Flavour '$LVM_TEST_FLAVOUR' does not exist">&2; initskip; }
@@ -127,10 +128,9 @@ elif test -z "$SKIP_ROOT_DM_CHECK" ; then
 fi
 
 echo "$TESTNAME" >TESTNAME
-
 # Require 50M of free space in testdir
-test "$(df -k -P . | awk '/\// {print $4}')" -gt 51200 || \
-	skip "Testing requires more then 50M of free space in directory $TESTDIR!\\n$(df -H | sed -e 's,^,## DF:   ,')"
+test "$(df -k -P . | awk '/\// {print $4}')" -gt $(( SKIP_WITH_LOW_SPACE * 1024 )) || \
+	skip "Testing requires more then ${SKIP_WITH_LOW_SPACE}M of free space in directory $TESTDIR!\\n$(df -H | sed -e 's,^,## DF:   ,')"
 
 echo "Kernel is $(uname -a)"
 # Report SELinux mode


