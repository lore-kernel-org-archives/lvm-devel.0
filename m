From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:16:11 -0400
Subject: master - tests: enable lvcreate cache tests with lvmlockd
Message-ID: <201805311416.w4VEGBUR031446@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=214235367b3500a586fc42232af34bd04ad14078
Commit:        214235367b3500a586fc42232af34bd04ad14078
Parent:        c516321325f41f6b1f9d9342e2b0d0507b5a30fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 15:56:08 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 15:56:08 2018 -0500

tests: enable lvcreate cache tests with lvmlockd

Tests that want to use lvcreate to create a new
origin LV and then combine it with an existing
cache pool to create a cache LV.
---
 test/shell/cache-metadata2.sh       |    2 +-
 test/shell/component-cache.sh       |    2 +-
 test/shell/lvchange-cache-mode.sh   |    2 +-
 test/shell/lvchange-cache.sh        |    2 +-
 test/shell/lvconvert-cache-abort.sh |    2 +-
 test/shell/lvconvert-cache-smq.sh   |    2 +-
 test/shell/profiles-cache.sh        |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
index a7586f7..684ae67 100644
--- a/test/shell/cache-metadata2.sh
+++ b/test/shell/cache-metadata2.sh
@@ -12,7 +12,7 @@
 
 # Exercise usage of metadata2 cache metadata format
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 # Until new version of cache_check tools - no integrity validation
diff --git a/test/shell/component-cache.sh b/test/shell/component-cache.sh
index 2060b31..87ca958 100644
--- a/test/shell/component-cache.sh
+++ b/test/shell/component-cache.sh
@@ -12,7 +12,7 @@
 
 # Exercise activation of cache component devices
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index 2bb8641..a34e517 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -12,7 +12,7 @@
 
 # Exercise changing of caching mode on both cache pool and cached LV.
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 73ad6c0..7e95f61 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index e771947..404f442 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -12,7 +12,7 @@
 
 # Exercise cache flushing is abortable
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvconvert-cache-smq.sh b/test/shell/lvconvert-cache-smq.sh
index e329aee..67710fa 100644
--- a/test/shell/lvconvert-cache-smq.sh
+++ b/test/shell/lvconvert-cache-smq.sh
@@ -12,7 +12,7 @@
 
 # Exercise conversion of cache and cache pool
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index dd4affb..9e17ebf 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -13,7 +13,7 @@
 # Exercise obtaining cache parameter from various sources
 # Either commmand line or metadata profile or implicit default...
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest


