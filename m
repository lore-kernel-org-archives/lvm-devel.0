From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 19:42:11 -0000
Subject: LVM2/tools lvconvert.c tools.h vgreduce.c lvco ...
Message-ID: <20110708194211.24892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 19:42:11

Modified files:
	tools          : lvconvert.c tools.h vgreduce.c 
Removed files:
	tools          : lvconvert.h 

Log message:
	remove unnecessary lvconvert.h

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.h.diff?cvsroot=lvm2&r1=1.1&r2=NONE

--- LVM2/tools/lvconvert.c	2011/06/29 02:06:26	1.165
+++ LVM2/tools/lvconvert.c	2011/07/08 19:42:11	1.166
@@ -16,7 +16,6 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "metadata.h"
-#include "lvconvert.h"
 
 struct lvconvert_params {
 	int snapshot;
--- LVM2/tools/tools.h	2011/06/01 19:21:03	1.75
+++ LVM2/tools/tools.h	2011/07/08 19:42:11	1.76
@@ -178,4 +178,7 @@
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv, unsigned background);
 
+int mirror_remove_missing(struct cmd_context *cmd,
+			  struct logical_volume *lv, int force);
+
 #endif
--- LVM2/tools/vgreduce.c	2011/05/07 15:52:16	1.111
+++ LVM2/tools/vgreduce.c	2011/07/08 19:42:11	1.112
@@ -15,7 +15,6 @@
 
 #include "tools.h"
 #include "lv_alloc.h"
-#include "lvconvert.h"
 
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {


