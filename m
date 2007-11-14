From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 14 Nov 2007 13:37:53 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20071114133753.5787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-11-14 13:37:51

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Make it compile with new lv_info_by_lvid() prototype

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/daemons/clvmd/lvm-functions.c	2007/08/24 08:29:39	1.34
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/11/14 13:37:51	1.35
@@ -223,7 +223,7 @@
 	}
 
 	/* If it's suspended then resume it */
-	if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
+	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
 		return EIO;
 
 	if (lvi.suspended)
@@ -269,7 +269,7 @@
 	}
 
 	/* Only suspend it if it exists */
-	if (!lv_info_by_lvid(cmd, resource, &lvi, 0))
+	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
 		return EIO;
 
 	if (lvi.exists) {
@@ -414,7 +414,7 @@
 			struct lvinfo lvi;
 
 			pthread_mutex_lock(&lvm_lock);
-			status = lv_info_by_lvid(cmd, resource, &lvi, 0);
+			status = lv_info_by_lvid(cmd, resource, &lvi, 0, 0);
 			pthread_mutex_unlock(&lvm_lock);
 			if (!status)
 				return EIO;


