From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 3 Aug 2010 20:22:32 -0000
Subject: LVM2 ./WHATS_NEW test/t-snapshot-merge.sh tool ...
Message-ID: <20100803202232.16049.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-03 20:22:32

Modified files:
	.              : WHATS_NEW 
	test           : t-snapshot-merge.sh 
	tools          : lvconvert.c 

Log message:
	Require logical volume(s) to be explicitly named for lvconvert --merge.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1694&r2=1.1695
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2010/08/03 18:19:43	1.1694
+++ LVM2/WHATS_NEW	2010/08/03 20:22:31	1.1695
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Require logical volume(s) to be explicitly named for lvconvert --merge.
   Avoid changing aligned pe_start as a side-effect of very verbose logging.
   Fix 'void*' arithmetic warnings in dbg_malloc.c.
   Fix 'void*' arithmetic warning in some functions from libdm-iface.c.
--- LVM2/test/t-snapshot-merge.sh	2010/04/23 19:27:11	1.6
+++ LVM2/test/t-snapshot-merge.sh	2010/08/03 20:22:31	1.7
@@ -49,6 +49,8 @@
 # now that snapshot LV is created: test if snapshot-merge target is available
 $(dmsetup targets | grep -q snapshot-merge) || exit 200
 lvs -a
+# make sure lvconvert --merge requires explicit LV listing
+not lvconvert --merge 2>err
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
--- LVM2/tools/lvconvert.c	2010/08/02 21:07:41	1.143
+++ LVM2/tools/lvconvert.c	2010/08/03 20:22:31	1.144
@@ -1738,9 +1738,14 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (lp.merge)
+	if (lp.merge) {
+		if (!argc) {
+			log_error("Please provide logical volume path");
+			return EINVALID_CMD_LINE;
+		}
 		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &lp,
 				       &lvconvert_merge_single);
+	}
 
 	return lvconvert_single(cmd, &lp);
 }


