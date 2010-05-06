From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 6 May 2010 19:01:28 -0000
Subject: LVM2/test check.sh t-lvconvert-repair-dmeventd.sh
Message-ID: <20100506190128.15824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-06 19:01:27

Modified files:
	test           : check.sh 
Added files:
	test           : t-lvconvert-repair-dmeventd.sh 

Log message:
	Add a basic test for dmeventd triggering lvconvert --repair. Needs improvement.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/test/t-lvconvert-repair-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-dmeventd.sh
+++ -	2010-05-06 19:01:27.406774000 +0000
@@ -0,0 +1,26 @@
+#!/bin/bash
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. ./test-utils.sh
+
+prepare_vg 5
+prepare_dmeventd
+
+which mkfs.ext2 || exit 200
+
+lvcreate -m 3 --ig -L 1 -n 4way $vg
+lvchange --monitor y $vg/4way
+disable_dev $dev2 $dev4
+mkfs.ext2 $DM_DEV_DIR/$vg/4way
+sleep 3 # FIXME : - (
+enable_dev $dev2 $dev4
+check mirror $vg 4way
+check mirror_legs $vg 4way 2
--- LVM2/test/check.sh	2010/04/12 19:33:58	1.2
+++ LVM2/test/check.sh	2010/05/06 19:01:26	1.3
@@ -98,6 +98,14 @@
 	if test -n "$3"; then mirror_log_on "$lv" "$3"; fi
 }
 
+mirror_legs() {
+	lv="$1/$2"
+	expect="$3"
+	lvdevices "$lv"
+	real=`lvdevices "$lv" | wc -w`
+	test "$expect" = "$real"
+}
+
 linear() {
 	lv="$1/$2"
 	lvs -ostripes "$lv" | grep -q "1" || {


