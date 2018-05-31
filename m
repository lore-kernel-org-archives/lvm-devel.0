From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 15:51:40 -0400
Subject: master - tests: enable lvmlockd with tests using lvcreate -H -L LV
Message-ID: <201805311951.w4VJpe2V020767@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08771bbbbf20298df0440dd8ca75ca10af60eb2f
Commit:        08771bbbbf20298df0440dd8ca75ca10af60eb2f
Parent:        8d9d32b315afd0fb2b674ca3bb857cb4ce2cbf2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 14:49:16 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 14:49:16 2018 -0500

tests: enable lvmlockd with tests using lvcreate -H -L LV

---
 test/shell/lvcreate-cache-no-tools.sh |    2 +-
 test/shell/lvcreate-cache-raid.sh     |    2 +-
 test/shell/lvcreate-cache.sh          |    2 +-
 test/shell/lvcreate-thin-cache.sh     |    4 ++--
 test/shell/lvextend-thin-cache.sh     |    2 +-
 test/shell/lvs-cache.sh               |    2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index c38ecfd..23528e4 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -12,7 +12,7 @@
 
 # Exercise creation of cache without cache_check
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-cache-raid.sh b/test/shell/lvcreate-cache-raid.sh
index d540d4e..d1d1c19 100644
--- a/test/shell/lvcreate-cache-raid.sh
+++ b/test/shell/lvcreate-cache-raid.sh
@@ -12,7 +12,7 @@
 
 # Exercise creation of cache and raids
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 8edbeb2..010c06f 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -15,7 +15,7 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
diff --git a/test/shell/lvcreate-thin-cache.sh b/test/shell/lvcreate-thin-cache.sh
index 0b9f3c8..f87526a 100644
--- a/test/shell/lvcreate-thin-cache.sh
+++ b/test/shell/lvcreate-thin-cache.sh
@@ -12,7 +12,7 @@
 
 # Exercise caching thin-pool's data LV
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
@@ -30,7 +30,7 @@ which mkfs.ext4 || skip
 aux prepare_pvs 2 64
 get_devs
 
-vgcreate -s 64K "$vg" "${DEVICES[@]}"
+vgcreate $SHARED -s 64K "$vg" "${DEVICES[@]}"
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 
diff --git a/test/shell/lvextend-thin-cache.sh b/test/shell/lvextend-thin-cache.sh
index 8983b7d..f7bbfd9 100644
--- a/test/shell/lvextend-thin-cache.sh
+++ b/test/shell/lvextend-thin-cache.sh
@@ -12,7 +12,7 @@
 
 # Exercise resize of cached thin pool data volumes
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 84ac026..62d45ac 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -15,7 +15,7 @@
 # Full CLI uses  --type
 # Shorthand CLI uses -H | --cache
 
-SKIP_WITH_LVMLOCKD=1
+
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest


