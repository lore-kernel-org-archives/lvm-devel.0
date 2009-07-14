From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 02:14:06 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgextend.c
Message-ID: <20090714021406.1906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 02:14:05

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgextend.c 

Log message:
	Remove READ_REQUIRE_RESIZEABLE from vgextend by moving check inside vg_extend.
	
	Move the check for the RESIZEABLE flag inside the vg_extend function.
	When we consolidated the vg locking, reading, and status flag checking,
	we tied the check for the RESIZEABLE flag to the vg_read() call.  The problem
	with this is you cannot know what other APIs the application my or may not
	call after a vg_read() call.  Thus the READ_REQUIRE_RESIZEABLE flag is not
	really ideal - ideally we should be checking for this flag on a specific
	operation, not inside the vg_read() call.  This patch moves one check inside
	the library.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.246&r2=1.247
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/lib/metadata/metadata.c	2009/07/10 21:19:37	1.246
+++ LVM2/lib/metadata/metadata.c	2009/07/14 02:14:04	1.247
@@ -439,6 +439,9 @@
 	struct physical_volume *pv;
 	struct cmd_context *cmd = vg->cmd;
 
+	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return 0;
+
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return 0;
--- LVM2/tools/vgextend.c	2009/07/10 20:09:21	1.46
+++ LVM2/tools/vgextend.c	2009/07/14 02:14:05	1.47
@@ -37,8 +37,7 @@
 	argv++;
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL,
-				READ_REQUIRE_RESIZEABLE);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
 		return ECMD_FAILED;


