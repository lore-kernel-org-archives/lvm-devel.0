From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Mar 2009 15:19:30 -0000
Subject: LVM2/tools vgck.c
Message-ID: <20090316151930.13034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-16 15:19:29

Modified files:
	tools          : vgck.c 

Log message:
	Fix warning in previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/tools/vgck.c	2009/03/16 14:34:58	1.19
+++ LVM2/tools/vgck.c	2009/03/16 15:19:29	1.20
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "metadata.h"
 
 static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 		       const char *vg_name,


