From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:01:39 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111011090139.30993.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:01:39

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Replace with debug
	
	Since the dm_tree_create already reports reason of error,
	use log_debug for this message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.240&r2=1.241

--- LVM2/lib/activate/dev_manager.c	2011/10/11 08:59:42	1.240
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 09:01:38	1.241
@@ -1147,7 +1147,7 @@
 	uint32_t s;
 
 	if (!(dtree = dm_tree_create())) {
-		log_error("Partial dtree creation failed for %s.", lv->name);
+		log_debug("Partial dtree creation failed for %s.", lv->name);
 		return NULL;
 	}
 


