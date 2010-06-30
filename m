From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 22:22:00 -0000
Subject: LVM2/test t-metadata-balance.sh
Message-ID: <20100630222200.4695.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 22:22:00

Modified files:
	test           : t-metadata-balance.sh 

Log message:
	Update metadata-balance test for --vgmetadatacopies 0.
	
	Should be equivalent to "unmanaged".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-balance.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-metadata-balance.sh	2010/06/28 20:40:27	1.2
+++ LVM2/test/t-metadata-balance.sh	2010/06/30 22:22:00	1.3
@@ -126,10 +126,13 @@
 	check_vg_field_ $vg vg_mda_count $(($mdacp * 4))
 	check_vg_field_ $vg vg_mda_copies unmanaged
 	check_vg_field_ $vg vg_mda_used_count $(($mdacp * 4))
-	echo --vgmetadatacopies 0 should be rejected for vgchange and vgcreate
-	not vgchange --vgmetadatacopies 0 $vg
+	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate
+	vgchange --vgmetadatacopies 0 $vg
+	check_vg_field_ $vg vg_mda_copies unmanaged
+	vgremove -f $vg
+	vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2 $dev4 $dev5
+	check_vg_field_ $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	not vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2 $dev4 $dev5
 done
 
 echo Test vgextend / vgreduce with vgmetadatacopies


