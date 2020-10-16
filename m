From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:42 +0000 (GMT)
Subject: stable-2.02 - tests: inittest supports SKIP_WITH_LOW_SPACE
Message-ID: <20201016191142.DD838396EC8D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd681efd9fa2d2fd74093e702c708461dc5f0348
Commit:        cd681efd9fa2d2fd74093e702c708461dc5f0348
Parent:        3f06b5c39c47e0540db0ca26c7c0b93ad19f123c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:25:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

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
index 967fc1f66..993dec5cf 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -50,6 +50,7 @@ SKIP_WITH_LVMETAD=${SKIP_WITH_LVMETAD-}
 SKIP_WITH_LVMPOLLD=${SKIP_WITH_LVMPOLLD-}
 SKIP_WITH_LVMLOCKD=${SKIP_WITH_LVMLOCKD-}
 SKIP_ROOT_DM_CHECK=${SKIP_ROOT_DM_CHECK-}
+SKIP_WITH_LOW_SPACE=${SKIP_WITH_LOW_SPACE-50}
 
 test -n "$LVM_TEST_FLAVOUR" || { echo "NOTE: Empty flavour">&2; initskip; }
 test -f "lib/flavour-$LVM_TEST_FLAVOUR" || { echo "NOTE: Flavour '$LVM_TEST_FLAVOUR' does not exist">&2; initskip; }
@@ -134,10 +135,9 @@ elif test -z "$SKIP_ROOT_DM_CHECK" ; then
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


