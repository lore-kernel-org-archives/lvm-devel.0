From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 23 Oct 2019 04:03:03 -0400
Subject: master - pre-release
Message-ID: <201910230803.x9N833Wj012321@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9391b1b9f0b73303fa21f8f92574d17ce4c2b02
Commit:        b9391b1b9f0b73303fa21f8f92574d17ce4c2b02
Parent:        23cc7ddc50e2800a6dc248de897a4c88c1514160
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 23 09:46:23 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 23 09:51:55 2019 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 705514f..faf0a28 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.06(2)-git (2019-06-15)
+2.03.06(2) (2019-10-23)
diff --git a/VERSION_DM b/VERSION_DM
index 4f5679d..92988a6 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.165-git (2019-06-15)
+1.02.165 (2019-10-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index 11b0acf..b72f172 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.03.06 - 
-================================
+Version 2.03.06 - 23rd October 2019
+===================================
   Add _cpool suffix to cache-pool LV name when used by caching LV.
   No longer store extra UUID for cmeta and cdata cachevol layer.
   Enhance activation of cache devices with cachevols.
@@ -7,7 +7,7 @@ Version 2.03.06 -
   Rename LV converted to cachevol to use _cvol suffix.
   Use normal LVs for wiping of cachevols.
   Reload cleanered cache DM only with cleaner policy.
-  Fix cmd return when zering of cachevol fails.
+  Fix cmd return when zeroing of cachevol fails.
   Extend lvs to show all VDO properties.
   Preserve VDO write policy with vdopool.
   Increase default vdo bio threads to 4.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ed56b89..d164d63 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.165 - 
-=================================
+Version 1.02.165 - 23rd October 2019
+====================================
   Add support for DM_DEVICE_GET_TARGET_VERSION.
   Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.


