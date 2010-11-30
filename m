From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:57:36 -0000
Subject: LVM2/lib/format1 import-export.c
Message-ID: <20101130225736.17433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:57:35

Modified files:
	lib/format1    : import-export.c 

Log message:
	Remove unneeded test for NULL
	
	Remove check for system_id (it is defined as int8_t[], so cannot be NULL).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/lib/format1/import-export.c	2010/09/30 21:06:51	1.115
+++ LVM2/lib/format1/import-export.c	2010/11/30 22:57:35	1.116
@@ -185,7 +185,7 @@
 	}
 
 	/* Generate system_id if PV is in VG */
-	if (!pvd->system_id || !*pvd->system_id)
+	if (!pvd->system_id[0])
 		if (!_system_id(cmd, (char *)pvd->system_id, ""))
 			return_0;
 


