From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:24:18 -0000
Subject: LVM2/lib activate/activate.c metadata/mirror.c
Message-ID: <20110617142418.4686.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:24:18

Modified files:
	lib/activate   : activate.c 
	lib/metadata   : mirror.c 

Log message:
	Add couple FIXMEs around suspicious code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/lib/activate/activate.c	2011/06/17 14:22:48	1.200
+++ LVM2/lib/activate/activate.c	2011/06/17 14:24:18	1.201
@@ -795,12 +795,14 @@
 		goto out;
 	}
 
+	/* FIXME: Is this fallback alright? */
 	if (activate_lv_excl(lv->vg->cmd, lv)) {
 		if (!deactivate_lv(lv->vg->cmd, lv))
 			stack;
+		/* FIXME: locally & exclusive are undefined. */
 		return 0;
 	}
-
+	/* FIXME: Check exclusive value here. */
 out:
 	if (locally)
 		*locally = l;
--- LVM2/lib/metadata/mirror.c	2011/06/11 00:03:07	1.152
+++ LVM2/lib/metadata/mirror.c	2011/06/17 14:24:18	1.153
@@ -2020,6 +2020,7 @@
 	}
 
 	if (vg_is_clustered(lv->vg)) {
+		/* FIXME: review check of lv_is_active_remotely */
 		if (!(lv->status & ACTIVATE_EXCL) &&
 		    !cluster_mirror_is_available(lv)) {
 			log_error("Shared cluster mirrors are not available.");


