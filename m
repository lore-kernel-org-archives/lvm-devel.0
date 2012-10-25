From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 25 Oct 2012 05:43:15 +0000 (UTC)
Subject: master - mirror: Avoid reading mirrors with failed devices in mirrored log
Message-ID: <20121025054315.BC28FA2C1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b248ba0a396d7fc9a459eea02cfdc70b33ce3441
Commit:        b248ba0a396d7fc9a459eea02cfdc70b33ce3441
Parent:        9fd7ac7d035f0b2f8dcc3cb19935eb181816bd76
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Oct 25 00:42:45 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Oct 25 00:42:45 2012 -0500

mirror:  Avoid reading mirrors with failed devices in mirrored log

Commit 9fd7ac7d035f0b2f8dcc3cb19935eb181816bd76 did not handle mirrors
that contained mirrored logs.  This is because the status line of the
mirror does not give an indication of the health of the mirrored log,
as you can see here:
        [root at bp-01 lvm2]# dmsetup status vg-lv vg-lv_mlog
        vg-lv: 0 409600 mirror 2 253:6 253:7 400/400 1 AA 3 disk 253:5 A
        vg-lv_mlog: 0 8192 mirror 2 253:3 253:4 7/8 1 AD 1 core
Thus, the possibility for LVM commands to hang still persists when mirror
have mirrored logs.  I discovered this while performing some testing that
does polling with 'pvs' while doing I/O and killing devices.  The 'pvs'
managed to get between the mirrored log device failure and the attempt
by dmeventd to repair it.  The result was a very nasty block in LVM
commands that is very difficult to remove - even for someone who knows
what is going on.  Thus, it is absolutely essential that the log of a
mirror be recursively checked for mirror devices which may be failed
as well.

Despite what the code comment says in the aforementioned commit...
+ * _mirrored_transient_status().  FIXME: It is unable to handle mirrors
+ * with mirrored logs because it does not have a way to get the status of
+ * the mirror that forms the log, which could be blocked.
... it is possible to get the status of the log because the log device
major/minor is given to us by the status output of the top-level mirror.
We can use that to query the log device for any DM status and see if it
is a mirror that needs to be bypassed.  This patch does just that and is
now able to avoid reading from mirrors that have failed devices in a
mirrored log.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   54 +++++++++++++++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index db776c0..b883bde 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid reading mirrors with failed devices in its mirrored log.
   Avoid reading from mirrors that have failed devices if they block I/O.
   Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
   Fix clvmd support for option -d and properly use its argument.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6cc57d0..40f719e 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -139,6 +139,7 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
  * _parse_mirror_status
  * @mirror_status_string
  * @image_health:  return for allocated copy of image health characters
+ * @log_device: return for 'dev_t' of log device
  * @log_health: NULL if corelog, otherwise alloc'ed log health char
  *
  * This function takes the mirror status string, breaks it up and returns
@@ -149,8 +150,10 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
  * Returns: 1 on success, 0 on failure
  */
 static int _parse_mirror_status(char *mirror_status_str,
-				char **images_health, char **log_health)
+				char **images_health,
+				dev_t *log_dev, char **log_health)
 {
+	int major, minor;
 	char *p = NULL;
 	char **args, **log_args;
 	unsigned num_devs, log_argc;
@@ -174,10 +177,14 @@ static int _parse_mirror_status(char *mirror_status_str,
 		return_0;
 
 	*log_health = NULL;
-	if (!strcmp(log_args[0], "disk") &&
-	    !(*log_health = dm_strdup(log_args[2])))
-		return_0;
-
+	*log_dev = 0;
+	if (!strcmp(log_args[0], "disk")) {
+		if (!(*log_health = dm_strdup(log_args[2])))
+			return_0;
+		if (sscanf(log_args[1], "%d:%d", &major, &minor) != 2)
+			return_0;
+		*log_dev = MKDEV((dev_t)major, minor);
+	}
 	if (!(*images_health = dm_strdup(args[2 + num_devs])))
 		return_0;
 
@@ -199,9 +206,7 @@ static int _parse_mirror_status(char *mirror_status_str,
  * attempting to read a mirror, a circular dependency would be created.)
  *
  * This function is a slimmed-down version of lib/mirror/mirrored.c:
- * _mirrored_transient_status().  FIXME: It is unable to handle mirrors
- * with mirrored logs because it does not have a way to get the status of
- * the mirror that forms the log, which could be blocked.
+ * _mirrored_transient_status().
  *
  * If a failed device is detected in the status string, then it must be
  * determined if 'block_on_error' or 'handle_errors' was used when
@@ -217,23 +222,17 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					  char *mirror_status_str)
 {
 	unsigned i, check_for_blocking = 0;
+	dev_t log_dev;
 	char *images_health, *log_health;
-
 	uint64_t s,l;
 	char *params, *target_type = NULL;
 	void *next = NULL;
 	struct dm_task *dmt;
 
 	if (!_parse_mirror_status(mirror_status_str,
-				  &images_health, &log_health))
+				  &images_health, &log_dev, &log_health))
 		goto_out;
 
-	if (log_health && (log_health[0] != 'A')) {
-		log_debug("%s: Mirror log device marked as failed",
-			  dev_name(dev));
-		check_for_blocking = 1;
-	}
-
 	for (i = 0; images_health[i]; i++)
 		if (images_health[i] != 'A') {
 			log_debug("%s: Mirror image %d marked as failed",
@@ -241,6 +240,29 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 			check_for_blocking = 1;
 		}
 
+	if (!check_for_blocking && log_dev) {
+		if (log_health[0] != 'A') {
+			log_debug("%s: Mirror log device marked as failed",
+				  dev_name(dev));
+			check_for_blocking = 1;
+		} else {
+			struct device *tmp_dev;
+			char buf[16];
+
+			if (dm_snprintf(buf, sizeof(buf), "%d:%d",
+					(int)MAJOR(log_dev),
+					(int)MINOR(log_dev)) < 0)
+				goto_out;
+
+			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 1)))
+				goto_out;
+
+			tmp_dev->dev = log_dev;
+			if (!device_is_usable(tmp_dev))
+				goto_out;
+		}
+	}
+
 	if (!check_for_blocking)
 		return 0;
 


