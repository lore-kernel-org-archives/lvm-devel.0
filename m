From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Jun 2008 11:32:15 -0000
Subject: LVM2 lib/activate/dev_manager.c tools/lvchange ...
Message-ID: <20080618113215.19939.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-06-18 11:32:14

Modified files:
	lib/activate   : dev_manager.c 
	tools          : lvchange.c 
	.              : WHATS_NEW 
Added files:
	test           : t-read-ahead.sh 

Log message:
	Improve/Fix read ahead 'auto' calculation for stripe_size
	Fix lvchange output for -r auto setting if auto is already set
	Add testcase for read ahead

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.905&r2=1.906

/cvs/lvm2/LVM2/test/t-read-ahead.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-read-ahead.sh
+++ -	2008-06-18 11:32:14.658366000 +0000
@@ -0,0 +1,68 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests basic functionality of read-ahead and ra regressions
+#
+
+test_description='Test read-ahead functionality'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  test -n "$d5" && losetup -d "$d5"
+  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
+}
+
+get_lvs_()
+{
+   case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+    *$2) true ;;
+    *) false ;;
+   esac
+}
+
+test_expect_success "set up temp files, loopback devices" \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
+   vg=$(this_test_)-test-vg-$$            &&
+   lv=$(this_test_)-test-lv-$$'
+
+test_expect_success "test various read ahead settings" \
+  'pvcreate "$d1"                                    &&
+   pvcreate "$d2"                                    &&
+   pvcreate "$d3"                                    &&
+   pvcreate "$d4"                                    &&
+   pvcreate "$d5"                                    &&
+   vgcreate -c n "$vg" "$d1" "$d2" "$d3" "$d4" "$d5" &&
+   lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     &&
+   lvdisplay "$vg"/"$lv"                             &&
+   lvchange -r auto "$vg"/"$lv" || true | grep auto  &&
+   get_lvs_ lv auto                                  &&
+   get_lvs_ lv_kernel 5120                           &&
+   lvchange -r 400 "$vg/$lv"                         &&
+   get_lvs_ lv 400                                   &&
+   vgremove -f "$vg"'
+
+test_done
+
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/lib/activate/dev_manager.c	2008/06/05 12:45:55	1.137
+++ LVM2/lib/activate/dev_manager.c	2008/06/18 11:32:14	1.138
@@ -928,8 +928,8 @@
 			break;
 		if (lv_is_cow(lv) && !layer)
 			break;
-		if (max_stripe_size < seg->stripe_size)
-			max_stripe_size = seg->stripe_size;
+		if (max_stripe_size < seg->stripe_size * seg->area_count)
+			max_stripe_size = seg->stripe_size * seg->area_count;
 	}
 
 	if (read_ahead == DM_READ_AHEAD_AUTO) {
--- LVM2/tools/lvchange.c	2008/05/21 14:10:11	1.91
+++ LVM2/tools/lvchange.c	2008/06/18 11:32:14	1.92
@@ -387,8 +387,11 @@
 	}
 
 	if (lv->read_ahead == read_ahead) {
-		log_error("Read ahead is already %u for \"%s\"",
-			  read_ahead, lv->name);
+		if (read_ahead == DM_READ_AHEAD_AUTO)
+			log_error("Read ahead is already auto for \"%s\"", lv->name);
+		else
+			log_error("Read ahead is already %u for \"%s\"",
+				  read_ahead, lv->name);
 		return 0;
 	}
 
--- LVM2/WHATS_NEW	2008/06/17 14:14:00	1.905
+++ LVM2/WHATS_NEW	2008/06/18 11:32:14	1.906
@@ -1,5 +1,8 @@
 Version 2.02.39 -
 ================================
+  Improve/Fix read ahead 'auto' calculation for stripe_size
+  Fix lvchange output for -r auto setting if auto is already set
+  Add testcase for read ahead
   Fix ambiguous use of identifier 'error_message_produced'.
   Begin syncing configure.in for merge/unification with device-mapper.
   Fix add_mirror_images not to dereference uninitialized log_lv upon failure.


