From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2010 13:31:31 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20100513133131.19610.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-13 13:31:30

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Do not print encryption key in message debug output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.367&r2=1.368
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW_DM	2010/04/30 15:48:39	1.367
+++ LVM2/WHATS_NEW_DM	2010/05/13 13:31:30	1.368
@@ -1,5 +1,6 @@
 Version 1.02.48 -
 =================================
+  Do not print encryption key in message debug output (cryptsetup luksResume).
 
 Version 1.02.47 - 30th April 2010
 =================================
--- LVM2/libdm/ioctl/libdm-iface.c	2010/05/03 22:08:38	1.73
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/05/13 13:31:30	1.74
@@ -1102,7 +1102,7 @@
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
 	if (!(dmt->message = dm_strdup(message))) {
-		log_error("dm_task_set_message: strdup(%s) failed", message);
+		log_error("dm_task_set_message: strdup failed");
 		return 0;
 	}
 
@@ -1724,6 +1724,18 @@
 	return r;
 }
 
+static const char *_sanitise_message(char *message)
+{
+	const char *sanitised_message = message ?: "";
+
+	/* FIXME: Check for whitespace variations. */
+	/* This traps what cryptsetup sends us. */
+	if (message && !strncasecmp(message, "key set", 7))
+		sanitised_message = "key set";
+
+	return sanitised_message;
+}
+
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned repeat_count)
 {
@@ -1805,7 +1817,7 @@
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->skip_lockfs ? "S " : "",
 		  dmt->query_inactive_table ? "I " : "",
-		  dmt->sector, dmt->message ? dmt->message : "",
+		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
 #ifdef DM_IOCTLS
 	if (ioctl(_control_fd, command, dmi) < 0) {


