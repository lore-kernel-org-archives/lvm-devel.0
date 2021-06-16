From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jun 2021 14:37:26 +0000 (GMT)
Subject: main - tests: fix skip in stress_single_thread.sh
Message-ID: <20210616143726.94B76385741E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5740e9646d08eb9804a40bf195cefa46e8006e2
Commit:        e5740e9646d08eb9804a40bf195cefa46e8006e2
Parent:        f8742b6df2a34df1867c7da6b1a057d2d23a7a37
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 16 09:37:04 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 16 09:37:04 2021 -0500

tests: fix skip in stress_single_thread.sh

---
 test/shell/stress_single_thread.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/stress_single_thread.sh b/test/shell/stress_single_thread.sh
index ed9ce13c5..7982e9dad 100644
--- a/test/shell/stress_single_thread.sh
+++ b/test/shell/stress_single_thread.sh
@@ -13,10 +13,10 @@
 
 SKIP_WITH_LVMPOLLD=1
 
-[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
-
 . lib/inittest
 
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
+
 aux prepare_vg 3
 
 for i in {1..1000}


