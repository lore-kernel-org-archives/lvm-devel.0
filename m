From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:40:47 -0000
Subject: LVM2/lib/metadata vg.h
Message-ID: <20101220134047.8645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:40:46

Modified files:
	lib/metadata   : vg.h 

Log message:
	Use const char * for name and old_name in vg
	
	Switch to use const char pointers to avoid changes of these structure
	members and having better control over, were these members could
	be modified.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/metadata/vg.h	2010/11/09 12:34:43	1.8
+++ LVM2/lib/metadata/vg.h	2010/12/20 13:40:46	1.9
@@ -43,8 +43,8 @@
 	uint64_t status;
 
 	struct id id;
-	char *name;
-	char *old_name;		/* Set during vgrename and vgcfgrestore */
+	const char *name;
+	const char *old_name;		/* Set during vgrename and vgcfgrestore */
 	char *system_id;
 
 	uint32_t extent_size;


