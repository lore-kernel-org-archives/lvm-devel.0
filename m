From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 24 Oct 2012 04:11:15 +0000 (UTC)
Subject: master - mirror: Avoid reading from mirrors that have failed devices
Message-ID: <20121024041115.A2ED6A1618@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fd7ac7d035f0b2f8dcc3cb19935eb181816bd76
Commit:        9fd7ac7d035f0b2f8dcc3cb19935eb181816bd76
Parent:        b873fc54baf12891158017cd732e01a7f19b3ac3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Oct 23 23:10:33 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Oct 23 23:10:33 2012 -0500

mirror:  Avoid reading from mirrors that have failed devices

Addresses: rhbz855398 (Allow VGs to be built on cluster mirrors),
           and other issues.

The LVM code attempts to avoid reading labels from devices that are
suspended to try to avoid situations that may cause the commands to
block indefinitely.  When scanning devices, 'ignore_suspended_devices'
can be set so the code (lib/activate/dev_manager.c:device_is_usable())
checks any DM devices it finds and avoids them if they are suspended.

The mirror target has an additional mechanism that can cause I/O to
be blocked.  If a device in a mirror fails, all I/O will be blocked
by the kernel until a new table (a linear target or a mirror with
replacement devices) is loaded.  The mirror indicates that this condition
has happened by marking a 'D' for the faulty device in its status
output.  This condition must also be checked by 'device_is_usable()' to
avoid the possibility of blocking LVM commands indefinitely due to an
attempt to read the blocked mirror for labels.

Until now, mirrors were avoided if the 'ignore_suspended_devices'
condition was set.  This check seemed to suggest, "if we are concerned
about suspended devices, then let's ignore mirrors altogether just
in case".  This is insufficient and doesn't solve any problems.  All
devices that are suspended are already avoided if
'ignore_suspended_devices' is set; and if a mirror is blocking because
of an error condition, it will block the LVM command regardless of the
setting of that variable.

Rather than avoiding mirrors whenever 'ignore_suspended_devices' is
set, this patch causes mirrors to be avoided whenever they are blocking
due to an error.  (As mentioned above, the case where a DM device is
suspended is already covered.)  This solves a number of issues that weren't
handled before.  For example, pvcreate (or any command that does a
pv_read or vg_read, which eventually call device_is_usable()) will be
protected from blocked mirrors regardless of how
'ignore_suspended_devices' is set.  Additionally, a mirror that is
neither suspended nor blocking is /allowed/ to be read regardless
of how 'ignore_suspended_devices' is set.  (The latter point being the
source of the fix for rhbz855398.)
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |  160 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 155 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ffbf4ef..db776c0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid reading from mirrors that have failed devices if they block I/O.
   Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
   Fix clvmd support for option -d and properly use its argument.
   Support use of option --yes for lvchange --persistent.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 31c1c27..6cc57d0 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -135,6 +135,154 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 	return r;
 }
 
+/*
+ * _parse_mirror_status
+ * @mirror_status_string
+ * @image_health:  return for allocated copy of image health characters
+ * @log_health: NULL if corelog, otherwise alloc'ed log health char
+ *
+ * This function takes the mirror status string, breaks it up and returns
+ * its components.  For now, we only return the health characters.  This
+ * is an internal function.  If there are more things we want to return
+ * later, we can do that then.
+ *
+ * Returns: 1 on success, 0 on failure
+ */
+static int _parse_mirror_status(char *mirror_status_str,
+				char **images_health, char **log_health)
+{
+	char *p = NULL;
+	char **args, **log_args;
+	unsigned num_devs, log_argc;
+
+	if (!dm_split_words(mirror_status_str, 1, 0, &p) ||
+	    !(num_devs = (unsigned) atoi(p)))
+		/* On errors, we must assume the mirror is to be avoided */
+		return_0;
+
+	p += strlen(p) + 1;
+	args = alloca((num_devs + 5) * sizeof(char *));
+
+	if ((unsigned)dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
+		return_0;
+
+	log_argc = (unsigned) atoi(args[3 + num_devs]);
+	log_args = alloca(log_argc * sizeof(char *));
+
+	if ((unsigned)dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
+				     log_argc, 0, log_args) < log_argc)
+		return_0;
+
+	*log_health = NULL;
+	if (!strcmp(log_args[0], "disk") &&
+	    !(*log_health = dm_strdup(log_args[2])))
+		return_0;
+
+	if (!(*images_health = dm_strdup(args[2 + num_devs])))
+		return_0;
+
+	return 1;
+}
+
+/*
+ * ignore_blocked_mirror_devices
+ * @dev
+ * @start
+ * @length
+ * @mirror_status_str
+ *
+ * When a DM 'mirror' target is created with 'block_on_error' or
+ * 'handle_errors', it will block I/O if there is a device failure
+ * until the mirror is reconfigured.  Thus, LVM should never attempt
+ * to read labels from a mirror that has a failed device.  (LVM
+ * commands are issued to repair mirrors; and if LVM is blocked
+ * attempting to read a mirror, a circular dependency would be created.)
+ *
+ * This function is a slimmed-down version of lib/mirror/mirrored.c:
+ * _mirrored_transient_status().  FIXME: It is unable to handle mirrors
+ * with mirrored logs because it does not have a way to get the status of
+ * the mirror that forms the log, which could be blocked.
+ *
+ * If a failed device is detected in the status string, then it must be
+ * determined if 'block_on_error' or 'handle_errors' was used when
+ * creating the mirror.  This info can only be determined from the mirror
+ * table.  The 'dev', 'start', 'length' trio allow us to correlate the
+ * 'mirror_status_str' with the correct device table in order to check
+ * for blocking.
+ *
+ * Returns: 1 if mirror should be ignored, 0 if safe to use
+ */
+static int _ignore_blocked_mirror_devices(struct device *dev,
+					  uint64_t start, uint64_t length,
+					  char *mirror_status_str)
+{
+	unsigned i, check_for_blocking = 0;
+	char *images_health, *log_health;
+
+	uint64_t s,l;
+	char *params, *target_type = NULL;
+	void *next = NULL;
+	struct dm_task *dmt;
+
+	if (!_parse_mirror_status(mirror_status_str,
+				  &images_health, &log_health))
+		goto_out;
+
+	if (log_health && (log_health[0] != 'A')) {
+		log_debug("%s: Mirror log device marked as failed",
+			  dev_name(dev));
+		check_for_blocking = 1;
+	}
+
+	for (i = 0; images_health[i]; i++)
+		if (images_health[i] != 'A') {
+			log_debug("%s: Mirror image %d marked as failed",
+				  dev_name(dev), i);
+			check_for_blocking = 1;
+		}
+
+	if (!check_for_blocking)
+		return 0;
+
+	/*
+	 * We avoid another system call if we can, but if a device is
+	 * dead, we have no choice but to look up the table too.
+	 */
+	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
+		goto_out;
+
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
+		goto_out;
+
+	if (activation_checks() && !dm_task_enable_checks(dmt))
+		goto_out;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	do {
+		next = dm_get_next_target(dmt, next, &s, &l,
+					  &target_type, &params);
+		if ((s == start) && (l == length)) {
+			if (strcmp(target_type, "mirror"))
+				goto_out;
+
+			if (strstr(params, "block_on_error") ||
+			    strstr(params, "handle_errors")) {
+				log_debug("%s: I/O blocked to mirror device",
+					  dev_name(dev));
+				return 1;
+			}
+		}
+	} while (next);
+	dm_task_destroy(dmt);
+
+	return 0;
+
+out:
+	return 1;
+}
+
 int device_is_usable(struct device *dev)
 {
 	struct dm_task *dmt;
@@ -180,15 +328,15 @@ int device_is_usable(struct device *dev)
 		goto out;
 	}
 
-	/* FIXME Also check for mirror block_on_error and mpath no paths */
-	/* For now, we exclude all mirrors */
-
+	/* FIXME Also check for mpath no paths */
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
-		/* Skip if target type doesn't match */
-		if (target_type && !strcmp(target_type, "mirror") && ignore_suspended_devices()) {
-			log_debug("%s: Mirror device %s not usable.", dev_name(dev), name);
+
+		if (target_type && !strcmp(target_type, "mirror") &&
+		    _ignore_blocked_mirror_devices(dev, start, length, params)) {
+			log_debug("%s: Mirror device %s not usable.",
+				  dev_name(dev), name);
 			goto out;
 		}
 


