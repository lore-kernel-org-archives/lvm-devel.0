From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:38:07 -0000
Subject: LVM2/tools pvchange.c
Message-ID: <20100628203807.19585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:38:06

Modified files:
	tools          : pvchange.c 

Log message:
	Set vg_mda_copies when pvchange --metadataignore is given.
	
	When a user explicitly sets a new mda ignore value for a PV, we
	should update vg_mda_copies accordingly.  When the VG is written
	out, the user would not want the new ignore state to get lost as
	a result of the vg_mda_copies value and logic in the vg_write
	path.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/tools/pvchange.c	2010/06/28 20:33:58	1.77
+++ LVM2/tools/pvchange.c	2010/06/28 20:38:06	1.78
@@ -147,6 +147,17 @@
 		if (!pv_mda_set_ignored(pv, mda_ignore)) {
 			goto out;
 		}
+		/*
+		 * Update vg_mda_copies based on the mdas in this PV.
+		 * This is most likely what the user would expect - if they
+		 * specify a specific PV to be ignored/un-ignored, they will
+		 * most likely not want LVM to turn around and change the
+		 * ignore / un-ignore value when it writes the VG to disk.
+		 * This does not guarantee this PV's ignore bits will be
+		 * preserved in future operations.
+		 */
+		if (!is_orphan(pv) && vg_mda_copies(vg))
+			vg_set_mda_copies(vg, vg_mda_used_count(vg));
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {


