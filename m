From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Jun 2009 20:17:34 -0000
Subject: LVM2 lib/metadata/metadata.c test/t-unlost-pv.sh
Message-ID: <20090610201734.2506.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-06-10 20:17:33

Modified files:
	lib/metadata   : metadata.c 
	test           : t-unlost-pv.sh 

Log message:
	Allow metadata correction even when PVs are missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unlost-pv.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/metadata/metadata.c	2009/06/10 16:14:40	1.226
+++ LVM2/lib/metadata/metadata.c	2009/06/10 20:17:32	1.227
@@ -1835,6 +1835,7 @@
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
 	unsigned use_precommitted = precommitted;
+	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
 	struct pv_list *pvl, *pvl2;
 	struct dm_list all_pvs;
@@ -2076,11 +2077,14 @@
 		log_warn("WARNING: Inconsistent metadata found for VG %s - updating "
 			 "to use version %u", vgname, correct_vg->seqno);
 
+		cmd->handles_missing_pvs = 1;
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
 			vg_release(correct_vg);
+			cmd->handles_missing_pvs = saved_handles_missing_pvs;
 			return NULL;
 		}
+		cmd->handles_missing_pvs = saved_handles_missing_pvs;
 
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
--- LVM2/test/t-unlost-pv.sh	2008/11/10 12:43:35	1.2
+++ LVM2/test/t-unlost-pv.sh	2009/06/10 20:17:33	1.3
@@ -29,7 +29,6 @@
 enable_dev $dev1
 check
 
-exit 0 # FIXME, bug demonstration code follows
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
 vgextend $vg $dev1


