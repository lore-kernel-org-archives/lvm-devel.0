From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:13:53 -0400
Subject: master - tests: fix skipping logic for lvmpolld and lvmlockd
Message-ID: <201805311413.w4VEDrnr031094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ac9f8d631cc6b340f4d3ad2cc35021e42d36ef6
Commit:        5ac9f8d631cc6b340f4d3ad2cc35021e42d36ef6
Parent:        6d14d5d16b92c520b5f4ee464f171684cac40735
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 23 12:56:33 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: fix skipping logic for lvmpolld and lvmlockd

---
 test/lib/inittest.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 5e900c0..c48ea13 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -59,7 +59,7 @@ test -n "$SKIP_WITH_CLVMD" && test "$LVM_TEST_LOCKING" = 3 && initskip
 test -n "$SKIP_WITHOUT_LVMETAD" && test -z "$LVM_TEST_LVMETAD" && initskip
 test -n "$SKIP_WITH_LVMETAD" && test -n "$LVM_TEST_LVMETAD" && initskip
 
-test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && initskip
+test -n "$SKIP_WITH_LVMPOLLD" && test -n "$LVM_TEST_LVMPOLLD" && test -z "$LVM_TEST_LVMLOCKD" && initskip
 
 test -n "$SKIP_WITH_LVMLOCKD" && test -n "$LVM_TEST_LVMLOCKD" && initskip
 
@@ -172,6 +172,8 @@ test -n "$LVM_TEST_LVMPOLLD" && {
 	aux prepare_lvmpolld
 }
 
+export SHARED=""
+
 if test -n "$LVM_TEST_LVMLOCKD" ; then
 	if test -n "$LVM_TEST_LOCK_TYPE_SANLOCK" ; then
 		aux lvmconf 'local/host_id = 1'


