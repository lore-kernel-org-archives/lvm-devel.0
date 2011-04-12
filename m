From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Apr 2011 14:13:18 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110412141318.7422.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-12 14:13:18

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Replace dm_snprintf with strncpy
	
	My previous patch fixed incorrect error check for dm_snprintf.
	However in this particular case - dm_snprintf has been used differently -
	just like strncpy + setting last char with '\0' - so the code had to return
	error - because the buffer was to short for whole string.
	
	Patch replaces it with real strncpy.
	Also test for alloca() failure is removed - as the program behaviour
	is rather undefined in this case - it never returns NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/lib/metadata/mirror.c	2011/04/09 19:05:24	1.149
+++ LVM2/lib/metadata/mirror.c	2011/04/12 14:13:17	1.150
@@ -1785,13 +1785,10 @@
 		lv_name = lv->name;
 		suffix = "_mlogtmp_%d";
 	} else if ((lv_name = strstr(lv->name, MIRROR_SYNC_LAYER))) {
-		len = lv_name - lv->name + 1;
-		if (!(tmp_name = alloca(len)) ||
-		    (dm_snprintf(tmp_name, len, "%s", lv->name) < 0)) {
-			log_error("mirror log name allocation failed");
-			return 0;
-		}
-		lv_name = tmp_name;
+		len = lv_name - lv->name;
+		tmp_name = alloca(len + 1);
+		tmp_name[len] = '\0';
+		lv_name = strncpy(tmp_name, lv->name, len);
 		suffix = "_mlog";
 	} else {
 		lv_name = lv->name;


