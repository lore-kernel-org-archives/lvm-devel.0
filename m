From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Sep 2019 14:02:24 -0400
Subject: master - Revert "tests: drop unnecessary pid from LVMTEST prefix"
Message-ID: <201909161802.x8GI2O2w012504@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13fb57bbb1deca9ea14e58a3a4edf284d3f4846c
Commit:        13fb57bbb1deca9ea14e58a3a4edf284d3f4846c
Parent:        6e1cf248d4a9520b6e342dc583f1e4f7d4c5f8fa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 16 13:01:50 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 16 13:01:50 2019 -0500

Revert "tests: drop unnecessary pid from LVMTEST prefix"

This reverts commit 51c105702f24d64f1adc25a692ef37e20878cec5.

it seems the test system still needs this for some reason
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 4914b29..a6cefa8 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -68,7 +68,7 @@ export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK
 
 TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
-PREFIX="${COMMON_PREFIX}"
+PREFIX="${COMMON_PREFIX}$$"
 
 # Check we are not conflickting with some exiting setup
 if test -z "$SKIP_ROOT_DM_CHECK" ; then


