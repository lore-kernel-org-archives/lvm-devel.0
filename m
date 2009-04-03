From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Apr 2009 14:23:17 -0000
Subject: LVM2/test t-mdata-strings.sh
Message-ID: <20090403142317.18345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-03 14:23:17

Modified files:
	test           : t-mdata-strings.sh 

Log message:
	Fix whitespace in t-mdata-strings.sh
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-mdata-strings.sh	2009/03/31 17:30:47	1.4
+++ LVM2/test/t-mdata-strings.sh	2009/04/03 14:23:17	1.5
@@ -19,7 +19,7 @@
 
 # 'set up temp files, loopback devices' 
 name=$(basename "$dev1")
-dmsetup rename "$name" "$PREFIX$pv_ugly" 
+dmsetup rename "$name" "$PREFIX$pv_ugly"
 dev1=$(dirname "$dev1")/$PREFIX$pv_ugly
 
 # 'pvcreate, vgcreate on filename with backslashed chars' 


