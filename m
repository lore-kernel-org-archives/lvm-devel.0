From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:03:39 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090701170339.24180.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:03:39

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Don't segfault in vg_release when vg->cmd is NULL.
	
	Sun May  3 13:06:14 CEST 2009  Petr Rockai <me@mornfall.net>
	* Don't segfault in vg_release when vg->cmd is NULL.
	
	Author: Petr Rockai <prockai@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.229&r2=1.230

--- LVM2/lib/metadata/metadata.c	2009/07/01 17:00:51	1.229
+++ LVM2/lib/metadata/metadata.c	2009/07/01 17:03:38	1.230
@@ -2165,7 +2165,7 @@
 	if (!vg || !vg->vgmem)
 		return;
 
-	if (vg->vgmem == vg->cmd->mem)
+	if (vg->cmd && vg->vgmem == vg->cmd->mem)
 		log_error("Internal error: global memory pool used for VG %s",
 			  vg->name);
 


