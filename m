From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 21:24:28 -0000
Subject: LVM2/test t-mdata-strings.sh
Message-ID: <20111023212428.22137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 21:24:27

Modified files:
	test           : t-mdata-strings.sh 

Log message:
	Test with -F flag
	
	grep need -F to check what we really want to test.
	Add better test for existing device.
	
	Currently this test DOES NOT work with real /dev handle via udev
	since our tool does not see such device listet through udev.
	
	FIXME: We might be able to see it at least through dmsetup table and
	use for lvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-mdata-strings.sh	2011/10/23 15:39:08	1.7
+++ LVM2/test/t-mdata-strings.sh	2011/10/23 21:24:27	1.8
@@ -23,11 +23,14 @@
 dmsetup rename "$name" "$PREFIX$pv_ugly"
 dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
 
+dmsetup table | grep -F "$pv_ugly"
+
 # 'pvcreate, vgcreate on filename with backslashed chars' 
 created=$dev1
 # when used with real udev without fallback, it will fail here
 pvcreate "$dev1" || created=$dev2
-pvs | should grep $dev1
+pvdisplay | should grep -F "$pv_ugly"
+should check pv_field "$dev1" pv_name "$dev1"
 vgcreate $vg "$created"
 # 'no parse errors and VG really exists' 
 vgs 2>err


