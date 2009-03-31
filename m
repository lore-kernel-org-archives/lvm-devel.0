From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2009 17:30:48 -0000
Subject: LVM2/test t-mdata-strings.sh
Message-ID: <20090331173048.16060.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-31 17:30:47

Modified files:
	test           : t-mdata-strings.sh 

Log message:
	Add some more special chars for device name test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-mdata-strings.sh	2008/09/30 17:47:34	1.3
+++ LVM2/test/t-mdata-strings.sh	2009/03/31 17:30:47	1.4
@@ -15,12 +15,12 @@
 
 aux prepare_devs 1
 
-pv_suffix="__\"!@#\$%^&*()'\\\"__"
+pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"
 
 # 'set up temp files, loopback devices' 
 name=$(basename "$dev1")
-dmsetup rename "$name" "$name$pv_suffix" 
-dev1=$(dirname "$dev1")/$name$pv_suffix
+dmsetup rename "$name" "$PREFIX$pv_ugly" 
+dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
 
 # 'pvcreate, vgcreate on filename with backslashed chars' 
 pvcreate "$dev1" 


