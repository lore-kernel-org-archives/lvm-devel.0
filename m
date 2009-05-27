From: agk@sourceware.org <agk@sourceware.org>
Date: 27 May 2009 13:07:38 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090527130738.24552.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-27 13:07:37

Modified files:
	tools          : lvcreate.c 

Log message:
	0->NULL (mbroz)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.189&r2=1.190

--- LVM2/tools/lvcreate.c	2009/05/21 03:04:53	1.189
+++ LVM2/tools/lvcreate.c	2009/05/27 13:07:37	1.190
@@ -566,27 +566,27 @@
 
 	if (!(segtype = get_segtype_from_string(cmd, "zero"))) {
 		log_error("Zero segment type for virtual origin not found");
-		return 0;
+		return NULL;
 	}
 
 	len = strlen(lv_name) + 32;
 	if (!(vorigin_name = alloca(len)) ||
 	    dm_snprintf(vorigin_name, len, "%s_vorigin", lv_name) < 0) {
 		log_error("Virtual origin name allocation failed.");
-		return 0;
+		return NULL;
 	}
 
 	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
 				   ALLOC_INHERIT, vg)))
-		return_0;
+		return_NULL;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
 		       NULL, ALLOC_INHERIT))
-		return_0;
+		return_NULL;
 
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
-		return_0;
+		return_NULL;
 
 	backup(vg);
 


