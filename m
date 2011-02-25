From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Feb 2011 14:12:15 -0000
Subject: LVM2 lib/format1/format1.c lib/format_text/arc ...
Message-ID: <20110225141215.4017.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-25 14:12:15

Modified files:
	lib/format1    : format1.c 
	lib/format_text: archiver.c 
	test           : t-pvcreate-usage.sh 

Log message:
	vgconvert is fixed now to work with the changes in metadata area handling - enable the tests.
	Add a small fix that preserves pe_start for lvm1 PVs when being converted.
	
	(this fix needs to be replaced with something more clever, but let's have this working now)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/format1/format1.c	2011/02/21 12:26:27	1.132
+++ LVM2/lib/format1/format1.c	2011/02/25 14:12:14	1.133
@@ -400,7 +400,7 @@
 
 static int _format1_pv_setup(const struct format_type *fmt,
 			     struct physical_volume *pv,
-			     struct volume_group *vg __attribute__((unused)))
+			     struct volume_group *vg)
 {
 	return _format1_pv_initialise(fmt, -1, 0, 0, vg->extent_size, 0, 0, pv);
 }
--- LVM2/lib/format_text/archiver.c	2011/02/25 13:59:47	1.42
+++ LVM2/lib/format_text/archiver.c	2011/02/25 14:12:14	1.43
@@ -296,6 +296,7 @@
 	struct pv_list *pvl;
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
+	uint32_t tmp;
 
 	/*
 	 * FIXME: Check that the PVs referenced in the backup are
@@ -320,11 +321,14 @@
 
 	/* Add any metadata areas on the PVs */
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		tmp = vg->extent_size;
+		vg->extent_size = 0;
 		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pvl->pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pvl->pv));
 			return 0;
 		}
+		vg->extent_size = tmp;
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg))
--- LVM2/test/t-pvcreate-usage.sh	2011/02/21 12:37:33	1.18
+++ LVM2/test/t-pvcreate-usage.sh	2011/02/25 14:12:14	1.19
@@ -133,18 +133,18 @@
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
-#pvcreate --dataalignment 256k $dev1
-#vgcreate -s 1m $vg $dev1
-#vgconvert -M1 $vg
-#vgconvert -M2 $vg
-#check pv_field $dev1 pe_start 256.00k
-#vgremove $vg
+pvcreate --dataalignment 256k $dev1
+vgcreate -s 1m $vg $dev1
+vgconvert -M1 $vg
+vgconvert -M2 $vg
+check pv_field $dev1 pe_start 256.00k
+vgremove $vg
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
 pvcreate --dataalignment 10k $dev1
 vgcreate -s 1m $vg $dev1
 not vgconvert -M1 $vg
-#vgremove $vg
+vgremove $vg
 
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,


