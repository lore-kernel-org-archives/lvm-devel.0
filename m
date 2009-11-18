From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Nov 2009 18:23:46 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20091118182346.28668.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-18 18:23:46

Modified files:
	lib/metadata   : mirror.c 

Log message:
	Add an extra memlock_inc() to _remove_mirror_images to properly balance
	reference counting (see code comment for details).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93

--- LVM2/lib/metadata/mirror.c	2009/10/14 14:55:44	1.92
+++ LVM2/lib/metadata/mirror.c	2009/11/18 18:23:46	1.93
@@ -612,6 +612,17 @@
 		return 0;
 	}
 
+	/*
+	 * The code above calls a suspend_lv once, however we now need to
+	 * resume 2 LVs, due to image removal: the mirror image itself above,
+	 * and now the remaining mirror LV. Since suspend_lv/resume_lv call
+	 * memlock_inc/memlock_dec and these need to be balanced, we need to
+	 * call an extra memlock_inc() here to balance for the second resume,
+	 * which could otherwise either deadlock due to suspended devices, or
+	 * alternatively drop memlock_count below 0.
+	 */
+	memlock_inc();
+
 	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Problem reactivating %s", mirrored_seg->lv->name);
 		return 0;


