From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2008 15:31:19 -0000
Subject: LVM2 lib/config/defaults.h tools/vgcreate.c
Message-ID: <20080117153119.6074.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-17 15:31:18

Modified files:
	lib/config     : defaults.h 
	tools          : vgcreate.c 

Log message:
	fix default extent_size

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/lib/config/defaults.h	2008/01/14 21:07:58	1.38
+++ LVM2/lib/config/defaults.h	2008/01/17 15:31:18	1.39
@@ -64,8 +64,7 @@
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
-#define DEFAULT_PE_SIZE 4096	/* In KB */
-
+#define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
--- LVM2/tools/vgcreate.c	2008/01/15 22:56:30	1.55
+++ LVM2/tools/vgcreate.c	2008/01/17 15:31:18	1.56
@@ -34,7 +34,7 @@
 	}
 
 	vp_def.vg_name = NULL;
-	vp_def.extent_size = DEFAULT_PE_SIZE;
+	vp_def.extent_size = DEFAULT_EXTENT_SIZE * 2;
 	vp_def.max_pv = 0;
 	vp_def.max_lv = 0;
 	vp_def.alloc = ALLOC_NORMAL;


