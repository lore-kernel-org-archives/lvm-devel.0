From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Aug 2008 13:34:34 -0000
Subject: LVM2/test t-covercmd.sh
Message-ID: <20080820133434.29420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-20 13:34:33

Modified files:
	test           : t-covercmd.sh 

Log message:
	fail testcase for failed commands inside the for loop

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-covercmd.sh	2008/08/13 14:28:17	1.2
+++ LVM2/test/t-covercmd.sh	2008/08/20 13:34:33	1.3
@@ -54,35 +54,36 @@
    lvcreate -n "$lv" -l 1%FREE -i5 -I256 "$vg"'
 
 test_expect_success "test *scan and *display tools" \
-  'pvscan &&
-   vgscan &&
-   lvscan &&
-   for i in b k m g t p e H B K M G T P E ; do pvdisplay --units $i ; done &&
+  'pvscan              &&
+   vgscan              &&
+   lvscan              &&
+   lvmdiskscan         &&
    vgdisplay --units k &&
-   lvdisplay --units g'
+   lvdisplay --units g &&
+   for i in b k m g t p e H B K M G T P E ; do \
+     pvdisplay --units "$i" "$d1" || return $? ; done'
 
 test_expect_success "test vgexport vgimport tools" \
-  'vgchange -an "$vg" &&
-   vgexport "$vg" &&
-   vgimport "$vg" &&
+  'vgchange -an "$vg"  &&
+   vgexport "$vg"      &&
+   vgimport "$vg"      &&
    vgchange -ay "$vg"'
 
 # "-persistent y --major 254 --minor 20"
+# "-persistent n"
 test_expect_success "test various lvm utils" \
-  'lvmdiskscan &&
-   for i in dumpconfig formats segtypes ; do lvm $i ; done &&
-   for i in pr \"p rw\" an ay -refresh  "-monitor y" "-monitor n" \
-      "-persistent n" -resync \
-      "-addtag MYTAG" "-deltag MYTAG"; \
-      do lvchange -$i "$vg"/"$lv" ; done &&
-   pvck "$d1" &&
-   vgck "$vg" &&
-   lvrename "$vg" "$lv" "$lv-rename" &&
-   vgcfgbackup -f $(pwd)/backup.$$ "$vg"  &&
-   vgchange -an "$vg" &&
-   pvdisplay &&
-   vgcfgrestore  -f $(pwd)/backup.$$ "$vg" &&
-   vgremove -f "$vg" &&
+  'for i in dumpconfig formats segtypes 
+     do lvm "$i" || return $? ; done                 &&
+   for i in pr "p rw" an ay "-monitor y" "-monitor n" \
+     -resync -refresh "-addtag MYTAG" "-deltag MYETAG"
+     do lvchange -$i "$vg"/"$lv" || return $? ; done &&
+   pvck "$d1"                                        &&
+   vgck "$vg"                                        &&
+   lvrename "$vg" "$lv" "$lv-rename"                 &&
+   vgcfgbackup -f "$(pwd)/backup.$$" "$vg"           &&
+   vgchange -an "$vg"                                &&
+   vgcfgrestore  -f "$(pwd)/backup.$$" "$vg"         &&
+   vgremove -f "$vg"                                 &&
    pvresize --setphysicalvolumesize 10M "$d1"'
 
 test_expect_failure "test various errors and obsoleted tools" \


