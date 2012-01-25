From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:42:10 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120125214210.28177.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:42:10

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Add breaks for cases

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/25 13:06:57	1.30
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/01/25 21:42:09	1.31
@@ -230,9 +230,9 @@
 		return -1;
 
 	switch (a->type) {
-	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str);
-	case DM_CFG_FLOAT: r = (a->v.f == b->v.f);
-	case DM_CFG_INT: r = (a->v.i == b->v.i);
+	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str); break;
+	case DM_CFG_FLOAT: r = (a->v.f == b->v.f); break;
+	case DM_CFG_INT: r = (a->v.i == b->v.i); break;
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}
 


