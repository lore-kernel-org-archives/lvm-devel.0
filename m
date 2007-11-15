From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2007 21:30:53 -0000
Subject: LVM2 lib/locking/locking.c lib/locking/locking ...
Message-ID: <20071115213053.26575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-15 21:30:52

Modified files:
	lib/locking    : locking.c locking.h 
	tools          : pvdisplay.c toollib.c vgreduce.c 

Log message:
	more vg_read lock fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/lib/locking/locking.c	2007/11/02 13:06:41	1.41
+++ LVM2/lib/locking/locking.c	2007/11/15 21:30:52	1.42
@@ -335,6 +335,11 @@
 {
 	char resource[258] __attribute((aligned(8)));
 
+	if (flags == LCK_NONE) {
+		log_debug("Internal error: %s: LCK_NONE lock requested", vol);
+		return 1;
+	}
+
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		/* Lock VG to change on-disk metadata. */
--- LVM2/lib/locking/locking.h	2007/11/15 02:55:22	1.36
+++ LVM2/lib/locking/locking.h	2007/11/15 21:30:52	1.37
@@ -86,7 +86,7 @@
 /*
  * Common combinations
  */
-#define LCK_NONE		0
+#define LCK_NONE		(LCK_VG | LCK_NULL)
 
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
--- LVM2/tools/pvdisplay.c	2007/11/15 02:20:03	1.43
+++ LVM2/tools/pvdisplay.c	2007/11/15 21:30:52	1.44
@@ -31,6 +31,7 @@
 		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
 					    LCK_VG_READ, CLUSTERED, 0))) {
                  	log_error("Skipping volume group %s", vg_name);
+			/* FIXME If CLUSTERED should return ECMD_PROCESSED here */
                  	return ECMD_FAILED;
          	}
 
--- LVM2/tools/toollib.c	2007/11/15 02:20:03	1.116
+++ LVM2/tools/toollib.c	2007/11/15 21:30:52	1.117
@@ -443,10 +443,9 @@
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			return ret_max;
+			break;
 	}
 
-out:
 	if (vg_name)
 		unlock_vg(cmd, vg_name);
 
@@ -747,8 +746,15 @@
 			if (sigint_caught())
 				return ret_max;
 		}
-		if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
-		    !list_empty(vgnames)) {
+		if (vg) {
+			ret = process_each_pv_in_vg(cmd, vg, &tags,
+						    handle, process_single);
+			if (ret > ret_max)
+				ret_max = ret;
+			if (sigint_caught())
+				return ret_max;
+		} else if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
+			   !list_empty(vgnames)) {
 			list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
 					log_error("Can't lock %s: skipping", sll->str);
--- LVM2/tools/vgreduce.c	2007/11/14 18:41:05	1.70
+++ LVM2/tools/vgreduce.c	2007/11/15 21:30:52	1.71
@@ -539,7 +539,7 @@
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
-		ret = process_each_pv(cmd, argc, argv, vg, LCK_VG_WRITE, NULL,
+		ret = process_each_pv(cmd, argc, argv, vg, LCK_NONE, NULL,
 				      _vgreduce_single);
 
 	}


