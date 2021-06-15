From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Jun 2021 19:03:00 +0000 (GMT)
Subject: main - tests: add some LVM_TEST_LOCK_TYPE_IDM
Message-ID: <20210615190300.982A0385783E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8742b6df2a34df1867c7da6b1a057d2d23a7a37
Commit:        f8742b6df2a34df1867c7da6b1a057d2d23a7a37
Parent:        440d6ae79fb4df92c7992d3c1689ba4f2d242d6a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 15 14:02:18 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 15 14:02:45 2021 -0500

tests: add some LVM_TEST_LOCK_TYPE_IDM

---
 test/shell/stress_multi_threads_1.sh | 2 ++
 test/shell/stress_multi_threads_2.sh | 2 ++
 test/shell/stress_single_thread.sh   | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/test/shell/stress_multi_threads_1.sh b/test/shell/stress_multi_threads_1.sh
index c96fa244b..e76810bbb 100644
--- a/test/shell/stress_multi_threads_1.sh
+++ b/test/shell/stress_multi_threads_1.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
+
 aux prepare_devs 6
 get_devs
 
diff --git a/test/shell/stress_multi_threads_2.sh b/test/shell/stress_multi_threads_2.sh
index a035b5727..4e72b7447 100644
--- a/test/shell/stress_multi_threads_2.sh
+++ b/test/shell/stress_multi_threads_2.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
+
 aux prepare_devs 8
 get_devs
 
diff --git a/test/shell/stress_single_thread.sh b/test/shell/stress_single_thread.sh
index e18d4900b..ed9ce13c5 100644
--- a/test/shell/stress_single_thread.sh
+++ b/test/shell/stress_single_thread.sh
@@ -13,6 +13,8 @@
 
 SKIP_WITH_LVMPOLLD=1
 
+[ -z "$LVM_TEST_LOCK_TYPE_IDM" ] && skip;
+
 . lib/inittest
 
 aux prepare_vg 3


