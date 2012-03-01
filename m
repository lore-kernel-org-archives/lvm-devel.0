From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:50:36 -0000
Subject: LVM2/tools dmsetup.c
Message-ID: <20120301215036.15927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:50:36

Modified files:
	tools          : dmsetup.c 

Log message:
	Test alloc fail

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.183&r2=1.184

--- LVM2/tools/dmsetup.c	2012/02/28 14:24:57	1.183
+++ LVM2/tools/dmsetup.c	2012/03/01 21:50:35	1.184
@@ -380,7 +380,9 @@
 		return NULL;
 	}
 
-	split_name->subsystem = _extract_uuid_prefix(uuid, separator);
+	if (!(split_name->subsystem = _extract_uuid_prefix(uuid, separator)))
+		return_NULL;
+
 	split_name->vg_name = split_name->lv_name =
 	    split_name->lv_layer = (char *) "";
 


