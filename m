From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 05 Oct 2011 15:13:19 -0500
Subject: [PATCH] Fix vgsplit for mirrored-log mirrors
Message-ID: <1317845599.12903.8.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes the following problem reported by "ben <benscott@nwlink.com>".

vgsplit fails with mirrored mirror log

#lvs --all -o lv_name,lv_attr,devices
 LV                       Attr   Devices                                                       
 MyMirror                 mwi--
 [MyMirror_mimage_0]      Iwi--- /dev/sdq(0)                                                   
 [MyMirror_mimage_1]      Iwi--- /dev/sdo(0)                                                   
 [MyMirror_mimage_2]      Iwi--- /dev/sdi(0)                                                   
 [MyMirror_mlog]          mwi---            
 [MyMirror_mlog_mimage_0] Iwi--- /dev/sds(0)                                                   
 [MyMirror_mlog_mimage_1] Iwi--- /dev/sde(0)                                                   

#vgsplit -v "TestA" "TestB" "/dev/sdq" "/dev/sdo" "/dev/sdi" "/dev/sds" 
"/dev/sde"
   Checking for volume group "TestA"
   Checking for new volume group "TestB"
   Archiving volume group "TestA" metadata (seqno 213).
 Can't split mirror MyMirror between two Volume Groups

Index: LVM2/tools/vgsplit.c
===================================================================
--- LVM2.orig/tools/vgsplit.c
+++ LVM2/tools/vgsplit.c
@@ -163,7 +163,7 @@ static int _move_mirrors(struct volume_g
 {
 	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
-	struct lv_segment *seg;
+	struct lv_segment *seg, *log_seg;
 	unsigned s, seg_in, log_in;
 
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
@@ -179,7 +179,20 @@ static int _move_mirrors(struct volume_g
 			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
 			    seg_in++;
 
-		log_in = (!seg->log_lv || _lv_is_in_vg(vg_to, seg->log_lv));
+		log_in = !seg->log_lv;
+		if (seg->log_lv) {
+			log_seg = first_seg(seg->log_lv);
+			if (seg_is_mirrored(log_seg)) {
+				log_in = 1;
+
+				/* Ensure each log dev is in vg_to */
+				for (s = 0; s < log_seg->area_count; s++)
+					log_in = log_in &&
+						_lv_is_in_vg(vg_to,
+							     seg_lv(log_seg, s));
+			} else
+				log_in = _lv_is_in_vg(vg_to, seg->log_lv);
+		}
 
 		if ((seg_in && seg_in < seg->area_count) ||
 		    (seg_in && seg->log_lv && !log_in) ||
Index: LVM2/test/t-vgsplit-operation.sh
===================================================================
--- LVM2.orig/test/t-vgsplit-operation.sh
+++ LVM2/test/t-vgsplit-operation.sh
@@ -93,6 +93,31 @@ COMM "vgsplit correctly splits mirror LV
 		fi 
 		lvremove -f $vg2/$lv1 
 		vgremove -f $vg2
+# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
+
+COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4
+		if [ $i = existing ]; then
+		  vgcreate -c n $vg2 $dev5
+		fi
+
+		lvcreate -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
+		    $dev1 $dev2 $dev3 $dev4
+
+		vgchange -an $vg1
+		if [ $j = PV ]; then
+		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3 $dev4
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 5 1 0
+		else
+		  check pvlv_counts $vg2 4 1 0
+		fi
+		lvremove -f $vg2/$lv1
+		vgremove -f $vg2
+# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
 		vgcreate -c n $vg1 $dev1 $dev2 



