From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 12:01:39 -0000
Subject: LVM2 ./WHATS_NEW tools/pvresize.c
Message-ID: <20101025120139.5490.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 12:01:38

Modified files:
	.              : WHATS_NEW 
	tools          : pvresize.c 

Log message:
	Print vg_name and do not to access vg->name
	
	Reported by clang as: Logic error Dereference of null pointer
	Replace pointer dereference with vg_name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1770&r2=1.1771
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/10/25 11:57:06	1.1770
+++ LVM2/WHATS_NEW	2010/10/25 12:01:38	1.1771
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix pointer for VG name in _pv_resize_single error code path.
   Fix warning for changed alignment requirements for dmeventd read/write func.
   Add global/metadata_read_only to use unrepaired metadata in read-only cmds.
   Don't take write lock in vgchange --refresh, --poll or --monitor.
--- LVM2/tools/pvresize.c	2010/05/19 01:16:41	1.35
+++ LVM2/tools/pvresize.c	2010/10/25 12:01:38	1.36
@@ -148,7 +148,7 @@
 	if (!is_orphan_vg(vg_name)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
-				  "volume group \"%s\"", pv_name, vg->name);
+				  "volume group \"%s\"", pv_name, vg_name);
 			goto out;
 		}
 		backup(vg);


