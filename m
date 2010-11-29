From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 10:11:52 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20101129101152.29135.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 10:11:51

Modified files:
	libdm          : libdm-common.c 

Log message:
	Cleanup remove test for NULL
	
	dm_free is testing NULL itself

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/libdm/libdm-common.c	2010/10/15 01:10:28	1.101
+++ LVM2/libdm/libdm-common.c	2010/11/29 10:11:50	1.102
@@ -250,10 +250,8 @@
 	char path[PATH_MAX];
 	struct stat st1, st2;
 
-	if (dmt->dev_name) {
-		dm_free(dmt->dev_name);
-		dmt->dev_name = NULL;
-	}
+	dm_free(dmt->dev_name);
+	dmt->dev_name = NULL;
 
 	/*
 	 * Path supplied for existing device?
@@ -292,8 +290,7 @@
 
 	if (strlen(name) >= DM_NAME_LEN) {
 		log_error("Name \"%s\" too long", name);
-		if (new_name)
-			dm_free(new_name);
+		dm_free(new_name);
 		return 0;
 	}
 
@@ -309,10 +306,7 @@
 
 int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 {
-	if (dmt->uuid) {
-		dm_free(dmt->uuid);
-		dmt->uuid = NULL;
-	}
+	dm_free(dmt->uuid);
 
 	if (!(dmt->uuid = dm_strdup(uuid))) {
 		log_error("dm_task_set_uuid: strdup(%s) failed", uuid);


