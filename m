From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2012 14:59:36 -0000
Subject: LVM2 ./WHATS_NEW tools/vgreduce.c
Message-ID: <20120330145936.1325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-30 14:59:36

Modified files:
	.              : WHATS_NEW 
	tools          : vgreduce.c 

Log message:
	Fix unlocking in error path of vgreduce
	
	When vg_read fails, it internally unlocks VG if it's been locked,
	so in error path we should skip unlock_vg for this case.
	(user would see ugly internal warning)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2374&r2=1.2375
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/WHATS_NEW	2012/03/30 11:39:52	1.2374
+++ LVM2/WHATS_NEW	2012/03/30 14:59:35	1.2375
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix unlocking volume group in vgreduce in error path.
   Exit immediately if LISTEN_PID env var incorrect during systemd handover.
   Detect VG name being part of the LV name in lvconvert --splitmirrors -n.
   Fix exclusive lvchange running from other node. (2.02.89)
--- LVM2/tools/vgreduce.c	2012/02/27 10:06:58	1.116
+++ LVM2/tools/vgreduce.c	2012/03/30 14:59:35	1.117
@@ -206,6 +206,7 @@
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
 	int saved_ignore_suspended_devices = ignore_suspended_devices();
+	int locked = 0;
 
 	if (!argc && !repairing) {
 		log_error("Please give volume group name and "
@@ -260,6 +261,8 @@
 	    && !arg_count(cmd, removemissing_ARG))
 		goto_out;
 
+	locked = !vg_read_error(vg);
+
 	if (repairing) {
 		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
@@ -275,6 +278,7 @@
 					READ_ALLOW_INCONSISTENT
 					| READ_ALLOW_EXPORTED);
 
+		locked |= !vg_read_error(vg);
 		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
 		    && vg_read_error(vg) != FAILED_INCONSISTENT)
 			goto_out;
@@ -314,7 +318,10 @@
 	}
 out:
 	init_ignore_suspended_devices(saved_ignore_suspended_devices);
-	unlock_and_release_vg(cmd, vg, vg_name);
+	if (locked)
+		unlock_vg(cmd, vg_name);
+
+	release_vg(vg);
 
 	return ret;
 


