From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Dec 2008 18:45:59 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20081212184559.26854.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-12-12 18:45:58

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Use dm_snprintf to avoid duplicating the snprintf compatibility code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/libdm/libdm-deptree.c	2008/12/11 16:25:51	1.48
+++ LVM2/libdm/libdm-deptree.c	2008/12/12 18:45:58	1.49
@@ -1224,17 +1224,14 @@
 
 /* simplify string emiting code */
 #define EMIT_PARAMS(p, str...)\
-	do {\
-		const size_t bufsize = paramsize - (size_t)p;\
-		int w;\
-		\
-		if ((w = snprintf(params + p, bufsize, str)) < 0\
-		    || ((size_t)w >= bufsize)) {\
-			stack; /* Out of space */\
-			return -1;\
-		}\
-		p += w;\
-	} while (0)
+do {\
+	int w;\
+	if ((w = dm_snprintf(params + p, paramsize - (size_t) p, str)) < 0) {\
+		stack; /* Out of space */\
+		return -1;\
+	}\
+	p += w;\
+} while (0)
 
 static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 			    struct load_segment *seg, char *params,


