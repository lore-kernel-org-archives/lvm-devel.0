From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Jan 2011 14:56:52 -0000
Subject: LVM2/test t-lvconvert-repair-snapshot.sh
Message-ID: <20110107145652.26268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-07 14:56:52

Added files:
	test           : t-lvconvert-repair-snapshot.sh 

Log message:
	Add a test for the interaction of snapshots of mirrors and lvconvert --repair.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-snapshot.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-lvconvert-repair-snapshot.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-repair-snapshot.sh
+++ -	2011-01-07 14:56:52.590474000 +0000
@@ -0,0 +1,24 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 5
+lvcreate -m 3 --ig -L 2M -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
+lvcreate -s $vg/4way -L 2M -n snap
+
+aux disable_dev $dev2 $dev4
+echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
+lvs -a -o +devices | not grep unknown
+vgreduce --removemissing $vg
+aux enable_dev $dev2 $dev4
+lvs -a -o +devices
+check mirror $vg 4way $dev5
+


