From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:29:54 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100107142954.23165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:29:53

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Just add '.' at the end of error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.308&r2=1.309

--- LVM2/lib/metadata/metadata.c	2010/01/05 16:09:34	1.308
+++ LVM2/lib/metadata/metadata.c	2010/01/07 14:29:53	1.309
@@ -2116,7 +2116,7 @@
 		}
 
 		if (strcmp(pvl->pv->vg_name, vg->name)) {
-			log_error(INTERNAL_ERROR "VG name for PV %s is corrupted",
+			log_error(INTERNAL_ERROR "VG name for PV %s is corrupted.",
 				  pv_dev_name(pvl->pv));
 			r = 0;
 		}


