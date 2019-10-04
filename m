From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:43 -0400
Subject: master - WHATS_NEW: update
Message-ID: <201910041533.x94FXhdA031093@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=414f903cdc161e553100af6ad03e68fbf94617c3
Commit:        414f903cdc161e553100af6ad03e68fbf94617c3
Parent:        ca70dc4540571bde2d10f4506f865e1caf398f00
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 17:30:52 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

WHATS_NEW: update

---
 WHATS_NEW    |    6 ++++++
 WHATS_NEW_DM |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a9bd750..767973c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.03.06 - 
 ================================
+  Extend lvs to show all VDO properties.
+  Preserve VDO write policy with vdopool.
+  Increase default vdo bio threads to 4.
+  Continue report when cache_status fails.
+  Add support for DM_GET_TARGET_VERSION into device_mapper.
+  Fix cmirrord usage of header files from device_mapper subdir.
   Allow standalone activation of VDO pool just like for thin-pools.
   Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 60a2b53..94492d4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.165 - 
 =================================
+  Add support for DM_GET_TARGET_VERSION.
   Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.
 


