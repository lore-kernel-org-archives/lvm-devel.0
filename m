From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Mar 2018 04:43:09 -0500
Subject: master - snapshot: skip invalid snapshost
Message-ID: <201803080943.w289h9gP019638@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7421252edccead6ce395cabc361ed175236bcb5c
Commit:        7421252edccead6ce395cabc361ed175236bcb5c
Parent:        a6fdb9d9d70f51c49ad11a87ab4243344e6701a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 10:32:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 8 10:39:44 2018 +0100

snapshot: skip invalid snapshost

When scanning DM device, skip automatically invalid snapshot devices.
They behave just like 'error' device.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d0bc386..16ad1d9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Automatically avoid reading invalid snapshots during device scan.
   Ensure COW device is writable even for read-only thick snapshots.
   Support activation of component LVs in read-only mode.
   Extend internal library to recognize and work with component LV.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b8b937d..dab1603 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -518,6 +518,24 @@ out:
         return r;
 }
 
+static int _ignore_invalid_snapshot(const char *params)
+{
+	struct dm_status_snapshot *s;
+	struct dm_pool *mem;
+	int r;
+
+	if (!(mem = dm_pool_create("invalid snapshots", 128)))
+		return_0;
+
+	if (!dm_get_status_snapshot(mem, params, &s))
+		return_0;
+
+	r = s->invalid;
+	dm_pool_destroy(mem);
+
+	return r;
+}
+
 /*
  * device_is_usable
  * @dev
@@ -633,6 +651,12 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check)
 			goto out;
 		}
 
+		if (target_type && !strcmp(target_type, TARGET_NAME_SNAPSHOT) &&
+		    _ignore_invalid_snapshot(params)) {
+			log_debug_activation("%s: Invalid %s device %s not usable.", dev_name(dev), target_type, name);
+			goto out;
+		}
+
 		/* TODO: extend check struct ? */
 		if (target_type && !strcmp(target_type, TARGET_NAME_THIN) &&
 		    !_ignore_unusable_thins(dev)) {


