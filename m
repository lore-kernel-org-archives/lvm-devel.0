From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 14:27:38 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090708142738.17885.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 14:27:38

Modified files:
	tools          : vgsplit.c 

Log message:
	Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
	
	Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
	These flags are no longer necessary.  We now check for existence
	in a differnet function, and it is not necessary to keep the lock.
	Removing these flags simplifies the new vg_read() interface.
	After this patch, we can fully remove LOCK_KEEP.
	READ_CHECK_EXISTENCE needs a bit more work before full removal.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/tools/vgsplit.c	2009/07/07 01:18:35	1.78
+++ LVM2/tools/vgsplit.c	2009/07/08 14:27:37	1.79
@@ -342,11 +342,13 @@
 		existing_vg = 1;
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_REQUIRE_RESIZEABLE |
-					   LOCK_NONBLOCKING | LOCK_KEEP |
-					   READ_CHECK_EXISTENCE);
+					   LOCK_NONBLOCKING);
 
-		if (vg_read_error(vg_to))
-			goto_bad;
+		if (vg_read_error(vg_to)) {
+			vg_release(vg_to);
+			stack;
+			goto bad2;
+		}
 
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -483,7 +485,8 @@
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+bad2:
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	return r;
 }


