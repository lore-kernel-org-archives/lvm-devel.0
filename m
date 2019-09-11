From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Sep 2019 15:02:13 -0400
Subject: master - tests: cache-single tests require version 1 10
Message-ID: <201909111902.x8BJ2DNf021988@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=715d2c778fb8f7b705a5c222e02638cdf845ea5b
Commit:        715d2c778fb8f7b705a5c222e02638cdf845ea5b
Parent:        3e5e7fd6c93517278b2451a08f47e16d052babbb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:48:03 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 11 14:01:55 2019 -0500

tests: cache-single tests require version 1 10

---
 test/shell/cache-single-types.sh |    2 +-
 test/shell/cache-single-usage.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index a973679..34a799a 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 10 0 || skip
 aux have_raid 1 3 5 || skip
 which mkfs.xfs || skip
 
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 09d5b10..4896d7a 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 10 0 || skip
 which mkfs.xfs || skip
 
 mount_dir="mnt"


