From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Apr 2008 13:08:49 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20080402130849.29631.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-02 13:08:49

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Suppress "Volume group not found" message when vgsplit of new VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.815&r2=1.816
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2008/04/01 22:40:12	1.815
+++ LVM2/WHATS_NEW	2008/04/02 13:08:49	1.816
@@ -1,5 +1,7 @@
 Version 2.02.34 -
 ===================================
+  Suppress excess messages when vgsplit into a new vg.
+  Suppress duplicate message when lvresize fails because of invalid vgname.
   Cache VG metadata internally while VG lock is held.
   Fix redundant lvresize message if vg doesn't exist.
   Fix another allocation bug with clvmd and large node IDs.
--- LVM2/tools/vgsplit.c	2008/03/26 17:26:32	1.52
+++ LVM2/tools/vgsplit.c	2008/04/02 13:08:49	1.53
@@ -220,6 +220,7 @@
 	int opt;
 	int active;
 	int existing_vg;
+	int old_suppress;
 	struct pv_list *pvl;
 
 	if (argc < 3) {
@@ -253,9 +254,11 @@
 	}
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
+	old_suppress = log_suppress(2);
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
+		log_suppress(old_suppress);
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -265,6 +268,7 @@
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto error;
 	} else {
+		log_suppress(old_suppress);
 		existing_vg = 0;
 
 		/* Set metadata format of original VG */


