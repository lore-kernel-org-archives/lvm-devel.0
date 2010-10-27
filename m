From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Oct 2010 09:16:32 -0000
Subject: LVM2/test t-dmeventd-restart.sh
Message-ID: <20101027091632.21771.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-27 09:16:31

Added files:
	test           : t-dmeventd-restart.sh 

Log message:
	Add a missed test for dmeventd -R.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-dmeventd-restart.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-dmeventd-restart.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-dmeventd-restart.sh
+++ -	2010-10-27 09:16:32.957440000 +0000
@@ -0,0 +1,32 @@
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
+lvcreate -m 2 --ig -L 1 -n 3way $vg
+lvchange --monitor y $vg/3way
+
+dmeventd -R -f &
+LOCAL_DMEVENTD="$!"
+
+sleep 1 # wait a bit, so we talk to the new dmeventd later
+
+lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
+grep 'already monitored' lvchange.out
+lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
+grep 'already monitored' lvchange.out


