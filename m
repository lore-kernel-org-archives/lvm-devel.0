From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 10:16:05 -0000
Subject: LVM2 lib/format_text/archiver.c lib/locking/cl ...
Message-ID: <20110128101605.32718.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 10:16:05

Modified files:
	lib/format_text: archiver.c 
	lib/locking    : cluster_locking.c 
	lib/misc       : timestamp.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Skip NULL check before dm_free
	
	dm_free checks for NULL itself.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/timestamp.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/lib/format_text/archiver.c	2011/01/05 15:06:10	1.37
+++ LVM2/lib/format_text/archiver.c	2011/01/28 10:16:04	1.38
@@ -69,8 +69,7 @@
 {
 	if (!cmd->archive_params)
 		return;
-	if (cmd->archive_params->dir)
-		dm_free(cmd->archive_params->dir);
+	dm_free(cmd->archive_params->dir);
 	memset(cmd->archive_params, 0, sizeof(*cmd->archive_params));
 }
 
@@ -183,8 +182,7 @@
 {
 	if (!cmd->backup_params)
 		return;
-	if (cmd->backup_params->dir)
-		dm_free(cmd->backup_params->dir);
+	dm_free(cmd->backup_params->dir);
 	memset(cmd->backup_params, 0, sizeof(*cmd->backup_params));
 }
 
--- LVM2/lib/locking/cluster_locking.c	2011/01/12 20:42:50	1.49
+++ LVM2/lib/locking/cluster_locking.c	2011/01/28 10:16:04	1.50
@@ -279,8 +279,7 @@
 	*response = rarray;
 
       out:
-	if (retbuf)
-		dm_free(retbuf);
+	dm_free(retbuf);
 
 	return status;
 }
--- LVM2/lib/misc/timestamp.c	2007/08/20 20:55:27	1.3
+++ LVM2/lib/misc/timestamp.c	2011/01/28 10:16:04	1.4
@@ -125,6 +125,5 @@
 
 void destroy_timestamp(struct timestamp *t)
 {
-	if (t)
-		dm_free(t);
+	dm_free(t);
 }
--- LVM2/libdm/ioctl/libdm-iface.c	2011/01/04 14:43:54	1.87
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/01/28 10:16:04	1.88
@@ -486,20 +486,11 @@
 		dm_free(t);
 	}
 
-	if (dmt->dev_name)
-		dm_free(dmt->dev_name);
-
-	if (dmt->newname)
-		dm_free(dmt->newname);
-
-	if (dmt->message)
-		dm_free(dmt->message);
-
 	_dm_zfree_dmi(dmt->dmi.v4);
-
-	if (dmt->uuid)
-		dm_free(dmt->uuid);
-
+	dm_free(dmt->dev_name);
+	dm_free(dmt->newname);
+	dm_free(dmt->message);
+	dm_free(dmt->uuid);
 	dm_free(dmt);
 }
 


