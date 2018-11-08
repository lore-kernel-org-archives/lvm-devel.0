From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 11:20:33 -0500
Subject: master - tests: futher test tunning
Message-ID: <201811081620.wA8GKXHm028735@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73132bc25414e8eb0a0c85708478b4dd797ce746
Commit:        73132bc25414e8eb0a0c85708478b4dd797ce746
Parent:        025332edc2c608e5892af373ebb764ac8ec5d8be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 17:19:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 17:19:39 2018 +0100

tests: futher test tunning

---
 test/shell/cache-single-options.sh |    2 +-
 test/shell/cache-single-thin.sh    |    1 +
 test/shell/cache-single-types.sh   |    1 +
 3 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index d9e7e01..d33bc2e 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_cache 1 3 0 || skip
+aux have_cache 1 10 0 || skip
 which mkfs.xfs || skip
 
 mount_dir="mnt"
diff --git a/test/shell/cache-single-thin.sh b/test/shell/cache-single-thin.sh
index 0a94326..33097ca 100644
--- a/test/shell/cache-single-thin.sh
+++ b/test/shell/cache-single-thin.sh
@@ -17,6 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux have_cache 1 3 0 || skip
+aux have_thin 1 0 0 || skip
 
 aux prepare_devs 5 80
 
diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
index d3bd5eb..1804e85 100644
--- a/test/shell/cache-single-types.sh
+++ b/test/shell/cache-single-types.sh
@@ -17,6 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux have_cache 1 3 0 || skip
+aux have_raid 1 3 5 || skip
 which mkfs.xfs || skip
 
 mount_dir="mnt"


