From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Sep 2011 11:04:12 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110902110412.30761.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-02 11:04:12

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Compile fix
	
	Reflecting change in dm_config_value  float r -> float f.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/08/31 12:39:58	1.24
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/09/02 11:04:12	1.25
@@ -192,7 +192,7 @@
 
 	switch (a->type) {
 	case DM_CFG_STRING: r = strcmp(a->v.str, b->v.str);
-	case DM_CFG_FLOAT: r = (a->v.r == b->v.r);
+	case DM_CFG_FLOAT: r = (a->v.f == b->v.f);
 	case DM_CFG_INT: r = (a->v.i == b->v.i);
 	case DM_CFG_EMPTY_ARRAY: return 0;
 	}


