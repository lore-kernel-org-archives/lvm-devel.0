From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 12:08:16 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20101025120816.8146.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 12:08:16

Modified files:
	tools          : toollib.c 

Log message:
	Reuse result of previous strchr
	
	Reported by clang as: Argument with 'nonnull' attribute passed null
	
	Reuse the result of the last strchr() call - make sure, 'st' point is not
	null for the next strchr() call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.209&r2=1.210

--- LVM2/tools/toollib.c	2010/09/23 12:02:34	1.209
+++ LVM2/tools/toollib.c	2010/10/25 12:08:15	1.210
@@ -869,7 +869,7 @@
 			while (*st == '/')
 				st++;
 
-		if (!strchr(vg_name, '/') || strchr(st, '/')) {
+		if (!st || strchr(st, '/')) {
 			log_error("\"%s\": Invalid path for Logical Volume",
 				  lv_name);
 			return 0;


