From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Oct 2013 12:22:55 +0000 (UTC)
Subject: master - pvscan: use major:minor as short form of --major and --minor arg for pvscan --cache
Message-ID: <20131022122255.107A86108F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a48137d39c51163ee29608c8c7ccbeecb4a7815
Commit:        0a48137d39c51163ee29608c8c7ccbeecb4a7815
Parent:        65456a4a29d8f25ab75af2145b8a6b2a9ff391e5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 22 13:52:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 22 13:52:18 2013 +0200

pvscan: use major:minor as short form of --major and --minor arg for pvscan --cache

Before, pvscan recognized either:
  pvscan --cache --major <major> --minor <minor>
or
  pvscan --cache <DevicePath>

When the device is gone and we need to notify lvmetad about device
removal, only --major/--minor works as we can't translate DevicePath
into major/minor pair anymore. The device does not exist in the system
and we don't keep DevicePath index in lvmetad cache to make the
translation internally into original major/minor pair. It would be
useless to keep this index just for this one exact case.

There's nothing bad about using "--major <major> --minor <minor>",
but it makes our life a bit harder when trying to make an
interconnection with systemd units, mainly with instantiated services
where only one and only one arg can be passed (which is encoded in the
service name).

This patch tries to make this easier by adding support for recognizing
the "<major>:<minor>" as a shortcut for the longer form
"--major <major> --minor <minor>". The rule here is simple: if the argument
starts with "/", it's a DevicePath, otherwise it's a <major>:<minor> pair.
---
 WHATS_NEW       |    1 +
 man/pvscan.8.in |    4 ++-
 tools/pvscan.c  |   61 +++++++++++++++++++++++++++++++++++++++++-------------
 3 files changed, 50 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 61aeb72..df81923 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Use major:minor as short form of --major and --minor arg for pvscan --cache.
   Remove 2>/dev/null from three lvm commands executed by vgimportclone.
   Add configure --enable-udev-systemd-background-jobs.
   Add lvm2-pvscan at .service to run pvscan as a service for lvmetad/autoactivation.
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 211c82b..37ecaaf 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -25,7 +25,9 @@ pvscan \- scan all disks for physical volumes
 .B \-\-minor
 .I minor
 |
-.IR DevicePath ]...
+.IR DevicePath
+|
+.IR major:minor ]...
 .SH DESCRIPTION
 pvscan scans all supported LVM block devices in the system for
 physical volumes.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3f16b05..b6a07bd 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -132,6 +132,27 @@ out:
 	return r;
 }
 
+static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t minor,
+					 activation_handler handler)
+{
+	char *buf;
+
+	if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
+		stack;
+	if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
+		if (buf)
+			dm_free(buf);
+		return 0;
+	}
+
+	log_print_unless_silent("Device %s not found. "
+				"Cleared from lvmetad cache.", buf ? : "");
+	if (buf)
+		dm_free(buf);
+
+	return 1;
+}
+
 static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret = ECMD_PROCESSED;
@@ -142,7 +163,6 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	int devno_args = 0;
 	struct arg_value_group_list *current_group;
 	dev_t devno;
-	char *buf;
 	activation_handler handler = NULL;
 
 	/*
@@ -193,11 +213,30 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	/* Process any command line PVs first. */
 	while (argc--) {
 		pv_name = *argv++;
-		dev = dev_cache_get(pv_name, cmd->lvmetad_filter);
-		if (!dev) {
-			log_error("Physical Volume %s not found.", pv_name);
-			ret = ECMD_FAILED;
-			continue;
+		if (pv_name[0] == '/') {
+			/* device path */
+			if (!(dev = dev_cache_get(pv_name, cmd->lvmetad_filter))) {
+				log_error("Physical Volume %s not found.", pv_name);
+				ret = ECMD_FAILED;
+				continue;
+			}
+		}
+		else {
+			/* device major:minor */
+			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
+				log_error("Failed to parse major:minor from %s", pv_name);
+				ret = ECMD_FAILED;
+				continue;
+			}
+			devno = MKDEV((dev_t)major, minor);
+			if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
+				if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {
+					stack;
+					ret = ECMD_FAILED;
+					break;
+				}
+				continue;
+			}
 		}
 		if (sigint_caught()) {
 			ret = ECMD_FAILED;
@@ -225,19 +264,11 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		devno = MKDEV((dev_t)major, minor);
 
 		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
-			if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
+			if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {
 				stack;
-			if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
 				ret = ECMD_FAILED;
-				if (buf)
-					dm_free(buf);
 				break;
 			}
-
-			log_print_unless_silent("Device %s not found. "
-						"Cleared from lvmetad cache.", buf ? : "");
-			if (buf)
-				dm_free(buf);
 			continue;
 		}
 		if (sigint_caught()) {


