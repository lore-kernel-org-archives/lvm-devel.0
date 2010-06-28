From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 21:49:31 -0000
Subject: LVM2/test t-covercmd.sh
Message-ID: <20100628214931.25206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 21:49:31

Modified files:
	test           : t-covercmd.sh 

Log message:
	Update t-covercmd pvck to take proper device argument.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-covercmd.sh	2009/07/07 19:28:57	1.7
+++ LVM2/test/t-covercmd.sh	2010/06/28 21:49:31	1.8
@@ -63,7 +63,7 @@
     lvchange -$i "$vg"/"$lv"
 done
 
-pvck "$d1"
+pvck "$dev1"
 vgck "$vg"
 lvrename "$vg" "$lv" "$lv-rename"
 vgcfgbackup -f "$(pwd)/backup.$$" "$vg"


