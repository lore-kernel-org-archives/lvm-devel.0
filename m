From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 17 Jan 2012 14:36:59 -0000
Subject: LVM2/libdm libdm-common.c ioctl/libdm-iface.c
Message-ID: <20120117143659.24114.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-01-17 14:36:59

Modified files:
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Move dm_task_set_newname from libdm-iface.c to libdm-common.c

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/libdm/libdm-common.c	2012/01/11 12:34:45	1.132
+++ LVM2/libdm/libdm-common.c	2012/01/17 14:36:58	1.133
@@ -342,6 +342,27 @@
 	return 1;
 }
 
+int dm_task_set_newname(struct dm_task *dmt, const char *newname)
+{
+	if (strchr(newname, '/')) {
+		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
+		return 0;
+	}
+
+	if (strlen(newname) >= DM_NAME_LEN) {
+		log_error("Name \"%s\" too long", newname);
+		return 0;
+	}
+
+	if (!(dmt->newname = dm_strdup(newname))) {
+		log_error("dm_task_set_newname: strdup(%s) failed", newname);
+		return 0;
+	}
+	dmt->new_uuid = 0;
+
+	return 1;
+}
+
 int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 {
 	dm_free(dmt->uuid);
--- LVM2/libdm/ioctl/libdm-iface.c	2012/01/09 12:26:15	1.131
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/01/17 14:36:59	1.132
@@ -747,27 +747,6 @@
 	return 1;
 }
 
-int dm_task_set_newname(struct dm_task *dmt, const char *newname)
-{
-	if (strchr(newname, '/')) {
-		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
-		return 0;
-	}
-
-	if (strlen(newname) >= DM_NAME_LEN) {
-		log_error("Name \"%s\" too long", newname);
-		return 0;
-	}
-
-	if (!(dmt->newname = dm_strdup(newname))) {
-		log_error("dm_task_set_newname: strdup(%s) failed", newname);
-		return 0;
-	}
-	dmt->new_uuid = 0;
-
-	return 1;
-}
-
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
 	if (!(dmt->message = dm_strdup(message))) {


