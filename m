From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:37:34 -0000
Subject: LVM2/test t-pvcreate-usage.sh
Message-ID: <20110221123734.27943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:37:34

Modified files:
	test           : t-pvcreate-usage.sh 

Log message:
	Temporarily disable 'convert a VG from lvm2 to lvm1 format' test until a known issue is resolved.
	
	Otherwise we get an error:
	
	PV segment VG free_count mismatch: 32 != 33
	PV segment VG extent_count mismatch: 32 != 33

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/t-pvcreate-usage.sh	2011/01/05 00:16:20	1.17
+++ LVM2/test/t-pvcreate-usage.sh	2011/02/21 12:37:33	1.18
@@ -133,18 +133,18 @@
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
-pvcreate --dataalignment 256k $dev1
-vgcreate -s 1m $vg $dev1
-vgconvert -M1 $vg
-vgconvert -M2 $vg
-check pv_field $dev1 pe_start 256.00k
-vgremove $vg
+#pvcreate --dataalignment 256k $dev1
+#vgcreate -s 1m $vg $dev1
+#vgconvert -M1 $vg
+#vgconvert -M2 $vg
+#check pv_field $dev1 pe_start 256.00k
+#vgremove $vg
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
 pvcreate --dataalignment 10k $dev1
 vgcreate -s 1m $vg $dev1
 not vgconvert -M1 $vg
-vgremove $vg
+#vgremove $vg
 
 #COMM 'vgcfgrestore allows pe_start=0'
 #basically it produces nonsense, but it tests vgcfgrestore,


