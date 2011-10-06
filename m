From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Oct 2011 14:17:47 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgsplit-operation.sh t ...
Message-ID: <20111006141747.1176.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-06 14:17:45

Modified files:
	.              : WHATS_NEW 
	test           : t-vgsplit-operation.sh 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit when there are mirrors that have mirrored logs.
	
	The problem as reported by "ben <benscott@nwlink.com>" on lvm-devel:
	
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
	
	AFTER FIX:
	
	[root at bp-01 ~]# lvs -a -o name,vg_name,devices vg new
	Volume group "new" not found
	Skipping volume group new
	LV                 VG   Devices
	lv                 vg   lv_mimage_0(0),lv_mimage_1(0)
	[lv_mimage_0]      vg   /dev/sdb1(0)
	[lv_mimage_1]      vg   /dev/sdc1(0)
	[lv_mlog]          vg   lv_mlog_mimage_0(0),lv_mlog_mimage_1(0)
	[lv_mlog_mimage_0] vg   /dev/sdh1(0)
	[lv_mlog_mimage_1] vg   /dev/sdi1(0)
	[root at bp-01 ~]# vgsplit vg new /dev/sd[bchi]1
	New volume group "new" successfully split from "vg"
	[root at bp-01 ~]# lvs -a -o name,vg_name,devices vg new
	LV                 VG   Devices
	lv                 new  lv_mimage_0(0),lv_mimage_1(0)
	[lv_mimage_0]      new  /dev/sdb1(0)
	[lv_mimage_1]      new  /dev/sdc1(0)
	[lv_mlog]          new  lv_mlog_mimage_0(0),lv_mlog_mimage_1(0)
	[lv_mlog_mimage_0] new  /dev/sdh1(0)
	[lv_mlog_mimage_1] new  /dev/sdi1(0)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2145&r2=1.2146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110

--- LVM2/WHATS_NEW	2011/10/04 20:49:24	1.2145
+++ LVM2/WHATS_NEW	2011/10/06 14:17:45	1.2146
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix vgsplit when there are mirrors that have mirrored logs.
   Clarify multi-name device filter pattern matching explanation in lvm.conf.5.
   Introduce lv_send_message and dev_manager_send_message.
   Introduce revert_lv for better pvmove cleanup.
--- LVM2/test/t-vgsplit-operation.sh	2011/01/05 00:16:20	1.27
+++ LVM2/test/t-vgsplit-operation.sh	2011/10/06 14:17:45	1.28
@@ -93,6 +93,31 @@
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
--- LVM2/tools/vgsplit.c	2011/08/30 14:55:19	1.109
+++ LVM2/tools/vgsplit.c	2011/10/06 14:17:45	1.110
@@ -163,7 +163,7 @@
 {
 	struct dm_list *lvh, *lvht;
 	struct logical_volume *lv;
-	struct lv_segment *seg;
+	struct lv_segment *seg, *log_seg;
 	unsigned s, seg_in, log_in;
 
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
@@ -179,7 +179,20 @@
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


