From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:15:41 -0000
Subject: LVM2/tools vgcreate.c
Message-ID: <20100224181541.14529.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:15:40

Modified files:
	tools          : vgcreate.c 

Log message:
	Refactor vgcreate to call new vg_change_tag() function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/tools/vgcreate.c	2009/12/28 18:34:45	1.77
+++ LVM2/tools/vgcreate.c	2010/02/24 18:15:40	1.78
@@ -94,16 +94,8 @@
 			goto bad;
 		}
 
-		if (!(vg->fid->fmt->features & FMT_TAGS)) {
-			log_error("Volume group format does not support tags");
-			goto bad;
-		}
-
-		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
-			log_error("Failed to add tag %s to volume group %s",
-				  tag, vp_new.vg_name);
-			goto bad;
-		}
+		if (!vg_change_tag(vg, tag, 1))
+			goto_bad;
 	}
 
 	if (vg_is_clustered(vg)) {


