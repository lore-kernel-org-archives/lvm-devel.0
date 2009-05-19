From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 09:48:32 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c test ...
Message-ID: <20090519094832.29152.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 09:48:32

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c 
	test           : t-vgcfgbackup-usage.sh 

Log message:
	Use PV UUID in hash for device name when exporting metadata.
	
	Currently code uses pv_dev_name() for hash when getting internal
	"pvX" name.
	
	This produce corrupted metadata if PVs are missing, pv->dev
	is NULL and all these missing devices returns one name
	(using "unknown device" for all missing devices as hash key).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1112&r2=1.1113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/05/14 16:46:12	1.1112
+++ LVM2/WHATS_NEW	2009/05/19 09:48:32	1.1113
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix metadata export for VG with missing PVs.
   Add vgimportclone and install it and the man page by default.
   Force max_lv restriction only for newly created LV.
   Remove unneeded import parameter from lv_create_empty.
--- LVM2/lib/format_text/export.c	2009/05/13 21:27:43	1.68
+++ LVM2/lib/format_text/export.c	2009/05/19 09:48:32	1.69
@@ -378,10 +378,19 @@
  * Get the pv%d name from the formatters hash
  * table.
  */
+static const char *_get_pv_name_from_uuid(struct formatter *f, char *uuid)
+{
+	return dm_hash_lookup(f->pv_names, uuid);
+}
+
 static const char *_get_pv_name(struct formatter *f, struct physical_volume *pv)
 {
-	return (pv) ? (const char *)
-	    dm_hash_lookup(f->pv_names, pv_dev_name(pv)) : "Missing";
+	char uuid[64] __attribute((aligned(8)));
+
+	if (!pv || !id_write_format(&pv->id, uuid, sizeof(uuid)))
+		return_NULL;
+
+	return _get_pv_name_from_uuid(f, uuid);
 }
 
 static int _print_pvs(struct formatter *f, struct volume_group *vg)
@@ -398,16 +407,16 @@
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 
-		if (!(name = _get_pv_name(f, pv)))
+		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
+			return_0;
+
+		if (!(name = _get_pv_name_from_uuid(f, buffer)))
 			return_0;
 
 		outnl(f);
 		outf(f, "%s {", name);
 		_inc_indent(f);
 
-		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			return_0;
-
 		outf(f, "id = \"%s\"", buffer);
 
 		if (!(buf = alloca(escaped_len(pv_dev_name(pv))))) {
@@ -621,7 +630,7 @@
 	int count = 0;
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	char buffer[32], *name;
+	char buffer[32], *uuid, *name;
 
 	if (!(f->mem = dm_pool_create("text pv_names", 512)))
 		return_0;
@@ -639,7 +648,11 @@
 		if (!(name = dm_pool_strdup(f->mem, buffer)))
 			return_0;
 
-		if (!dm_hash_insert(f->pv_names, pv_dev_name(pv), name))
+		if (!(uuid = dm_pool_zalloc(f->mem, 64)) ||
+		   !id_write_format(&pv->id, uuid, 64))
+			return_0;
+
+		if (!dm_hash_insert(f->pv_names, uuid, name))
 			return_0;
 	}
 
--- LVM2/test/t-vgcfgbackup-usage.sh	2008/11/11 15:29:24	1.1
+++ LVM2/test/t-vgcfgbackup-usage.sh	2009/05/19 09:48:32	1.2
@@ -11,14 +11,32 @@
 
 . ./test-utils.sh
 
-aux prepare_pvs 2
+aux prepare_pvs 4
 
 # vgcfgbackup handles similar VG names (bz458941)
 vg1=${PREFIX}vg00
-vg1=${PREFIX}vg01
+vg2=${PREFIX}vg01
 vgcreate $vg1 $dev1
 vgcreate $vg2 $dev2
 vgcfgbackup -f /tmp/bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
+vgremove -ff $vg1
+vgremove -ff $vg2
 
+# vgcfgbackup correctly stores metadata with missing PVs
+# and vgcfgrestore able to restore them when device reappears
+pv1_uuid=$(pvs --noheadings -o pv_uuid $dev1)
+pv2_uuid=$(pvs --noheadings -o pv_uuid $dev2)
+vgcreate $vg $devs
+lvcreate -l1 -n $lv1 $vg $dev1
+lvcreate -l1 -n $lv2 $vg $dev2
+lvcreate -l1 -n $lv3 $vg $dev3
+vgchange -a n $vg
+pvcreate -ff -y $dev1
+pvcreate -ff -y $dev2
+vgcfgbackup -f "$(pwd)/backup.$$" $vg
+sed 's/flags = \[\"MISSING\"\]/flags = \[\]/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
+pvcreate -ff -y -u $pv1_uuid $dev1
+pvcreate -ff -y -u $pv2_uuid $dev2
+vgcfgrestore -f "$(pwd)/backup.$$1" $vg


