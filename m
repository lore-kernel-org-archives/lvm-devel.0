From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 5 May 2012 02:08:48 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c test/ ...
Message-ID: <20120505020848.8450.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-05-05 02:08:47

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 
	test/shell     : lvconvert-mirror.sh 

Log message:
	Fix up-convert when mirror activation is controled by volume_list and tags.
	
	When mirrors are up-converted, a transient mirror layer is put in so that
	only the new devices are sync'ed.  That transient layer must carry the tags
	of the original mirror LV, otherwise it will fail to activate when activation
	is regulated by lvm.conf:activation/volume_list.  The conversion would then
	fail.
	
	The fix is to do exactly the same thing that is being done for linear ->
	mirror converting (lib/metadata/mirror.c:_init_mirror_log()).  We copy the
	tags temporarily for the new LV and remove them after the activation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2396&r2=1.2397
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.373&r2=1.374
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2012/05/01 19:21:24	1.2396
+++ LVM2/WHATS_NEW	2012/05/05 02:08:46	1.2397
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix up-convert when mirror activation is controled by volume_list and tags.
   Disallow snapshots of mirror segment type.
   Fix bug in cmirror that caused incorrect status info to print on some nodes.
   Remove statement that snapshots cannot be tagged from lvm man page.
--- LVM2/lib/metadata/lv_manip.c	2012/05/01 19:21:24	1.373
+++ LVM2/lib/metadata/lv_manip.c	2012/05/05 02:08:47	1.374
@@ -3682,9 +3682,10 @@
 					   const char *layer_suffix)
 {
 	int r;
-	struct logical_volume *layer_lv;
 	char *name;
 	size_t len;
+	struct str_list *sl;
+	struct logical_volume *layer_lv;
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
 	unsigned exclusive = 0;
@@ -3722,6 +3723,14 @@
 			return NULL;
 		}
 
+		/* Temporary tags for activation of the transient LV */
+		dm_list_iterate_items(sl, &lv_where->tags)
+			if (!str_list_add(cmd->mem, &layer_lv->tags, sl->str)) {
+				log_error("Aborting.  Unable to tag"
+					  " transient mirror layer.");
+				return NULL;
+			}
+
 		if (!vg_write(lv_where->vg)) {
 			log_error("Failed to write intermediate VG %s metadata for mirror conversion.", lv_where->vg->name);
 			return NULL;
@@ -3744,6 +3753,11 @@
 				  name, lv_where->vg->name);
 			return NULL;
 		}
+
+		/* Remove the temporary tags */
+		dm_list_iterate_items(sl, &lv_where->tags)
+			str_list_del(&layer_lv->tags, sl->str);
+
 	}
 
 	log_very_verbose("Inserting layer %s for %s",
--- LVM2/test/shell/lvconvert-mirror.sh	2012/03/16 13:00:06	1.5
+++ LVM2/test/shell/lvconvert-mirror.sh	2012/05/05 02:08:47	1.6
@@ -15,16 +15,28 @@
 	while test $(get lv_field $1 copy_percent) != "100.00"; do sleep 1; done
 }
 
-# convert from linear to 2-way mirror
 aux prepare_pvs 5 10
 # FIXME - test fails with extent size < 512k
 vgcreate -c n -s 512k $vg $(cat DEVICES)
 
+# convert from linear to 2-way mirror
 lvcreate -l2 -n $lv1 $vg "$dev1"
 lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
+# convert from linear to 2-way mirror - with tags and volume_list (bz683270)
+lvcreate -l2 -n $lv1 $vg --addtag hello
+lvconvert -i1 -m+1 $vg/$lv1 \
+    --config 'activation { volume_list = [ "@hello" ] }'
+lvremove -ff $vg
+
+# convert from 2-way to 3-way mirror - with tags and volume_list (bz683270)
+lvcreate -l2 -m1 -n $lv1 $vg --addtag hello
+lvconvert -i1 -m+1 $vg/$lv1 \
+    --config 'activation { volume_list = [ "@hello" ] }'
+lvremove -ff $vg
+
 # convert from 2-way mirror to linear
 lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m-1 $vg/$lv1


