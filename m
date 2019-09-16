From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Sep 2019 12:46:07 -0400
Subject: master - tests: drop unnecessary pid from LVMTEST prefix
Message-ID: <201909161646.x8GGk7WB009551@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51c105702f24d64f1adc25a692ef37e20878cec5
Commit:        51c105702f24d64f1adc25a692ef37e20878cec5
Parent:        df36a8eadfbbfe547cc734259dfc598cb773b59c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 14:52:13 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 14:52:13 2019 -0500

tests: drop unnecessary pid from LVMTEST prefix

---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a6cefa8..4914b29 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -68,7 +68,7 @@ export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK
 
 TESTOLDPWD=$(pwd)
 COMMON_PREFIX="LVMTEST"
-PREFIX="${COMMON_PREFIX}$$"
+PREFIX="${COMMON_PREFIX}"
 
 # Check we are not conflickting with some exiting setup
 if test -z "$SKIP_ROOT_DM_CHECK" ; then


