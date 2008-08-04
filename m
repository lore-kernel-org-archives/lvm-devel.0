From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2008 09:15:15 -0000
Subject: LVM2/test t-read-ahead.sh
Message-ID: <20080804091515.19123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-04 09:15:15

Modified files:
	test           : t-read-ahead.sh 

Log message:
	* parse error output for 'auto' keyword

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-read-ahead.sh	2008/06/18 11:32:13	1.1
+++ LVM2/test/t-read-ahead.sh	2008/08/04 09:15:15	1.2
@@ -54,7 +54,7 @@
    vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
    lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     &&
    lvdisplay "$vg"/"$lv"                             &&
-   lvchange -r auto "$vg"/"$lv" || true | grep auto  &&
+   lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto     &&
    get_lvs_ lv auto                                  &&
    get_lvs_ lv_kernel 5120                           &&
    lvchange -r 400 "$vg/$lv"                         &&


