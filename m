From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:10 +0000 (UTC)
Subject: master - mirror: detect attrs just once
Message-ID: <20140224201710.5ADC760ED7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5097463fb326df3f1dde654da4b59011b6135f1f
Commit:        5097463fb326df3f1dde654da4b59011b6135f1f
Parent:        95fe823eba5432bc395847076fbf187889c55cb1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 14:18:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:11 2014 +0100

mirror: detect attrs just once

Reorder detection of cmirrord. Now if cmirrord is not
running, target will not try to load kernel log module,
for communication with cmirrord.

Whole check for attrs now also happens just once.
---
 WHATS_NEW             |    1 +
 lib/mirror/mirrored.c |   47 +++++++++++++++++++++--------------------------
 2 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29d1554..005a321 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Improve detection of clustered mirror support.
   Enhance raid code with feature flags, for now checks for raid10.
   Move parsing of VG metadata from vg_commit() back to vg_write() (2.02.99)
   Avoid a PV label scan while in a critical section.
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index c3eb27b..57c6bba 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -150,7 +150,6 @@ static int _mirrored_text_export(const struct lv_segment *seg, struct formatter
 
 #ifdef DEVMAPPER_SUPPORT
 static int _block_on_error_available = 0;
-static unsigned _mirror_attributes = 0;
 
 static struct mirror_state *_mirrored_init_target(struct dm_pool *mem,
 					 struct cmd_context *cmd)
@@ -462,6 +461,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 {
 	static int _mirrored_checked = 0;
 	static int _mirrored_present = 0;
+	static unsigned _mirror_attributes = 0;
 	uint32_t maj, min, patchlevel;
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
@@ -469,6 +469,7 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 	unsigned kmaj, kmin, krel;
 
 	if (!_mirrored_checked) {
+		_mirrored_checked = 1;
 		_mirrored_present = target_present(cmd, "mirror", 1);
 
 		/*
@@ -492,14 +493,14 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 		      sscanf(vsn, "%u.%u.%u", &maj2, &min2, &patchlevel2) == 3 &&
 		      maj2 == 4 && min2 == 5 && patchlevel2 == 0)))	/* RHEL4U3 */
 			_block_on_error_available = 1;
-	}
 
-	/*
-	 * Check only for modules if atttributes requested and no previous check.
-	 * FIXME: Fails incorrectly if cmirror was built into kernel.
-	 */
-	if (attributes) {
-		if (!_mirror_attributes) {
+#ifdef CMIRRORD_PIDFILE
+		/*
+		 * The cluster mirror log daemon must be running,
+		 * otherwise, the kernel module will fail to make
+		 * contact.
+		 */
+		if (dm_daemon_is_running(CMIRRORD_PIDFILE)) {
 			/*
 			 * The dm-log-userspace module was added to the
 			 * 2.6.31 kernel.
@@ -508,31 +509,25 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 			    (sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) == 3) &&
 			    KERNEL_VERSION(kmaj, kmin, krel) < KERNEL_VERSION(2, 6, 31)) {
 				if (module_present(cmd, "log-clustered"))
-					_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 			} else if (module_present(cmd, "log-userspace"))
 				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 
 			if (!(_mirror_attributes & MIRROR_LOG_CLUSTERED))
-				log_verbose("Cluster mirror log module is not available");
-
-			/*
-			 * The cluster mirror log daemon must be running,
-			 * otherwise, the kernel module will fail to make
-			 * contact.
-			 */
-#ifdef CMIRRORD_PIDFILE
-			if (!dm_daemon_is_running(CMIRRORD_PIDFILE)) {
-				log_verbose("Cluster mirror log daemon is not running");
-				_mirror_attributes &= ~MIRROR_LOG_CLUSTERED;
-			}
+				log_verbose("Cluster mirror log module is not available.");
+		} else
+			log_verbose("Cluster mirror log daemon is not running.");
 #else
-			log_verbose("Cluster mirror log daemon not included in build");
-			_mirror_attributes &= ~MIRROR_LOG_CLUSTERED;
+		log_verbose("Cluster mirror log daemon not included in build.");
 #endif
-		}
-		*attributes = _mirror_attributes;
 	}
-	_mirrored_checked = 1;
+
+	/*
+	 * Check only for modules if atttributes requested and no previous check.
+	 * FIXME: Fails incorrectly if cmirror was built into kernel.
+	 */
+	if (attributes)
+		*attributes = _mirror_attributes;
 
 	return _mirrored_present;
 }


