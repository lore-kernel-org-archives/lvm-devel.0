From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2009 18:14:47 -0000
Subject: LVM2/test t-lvm-init.sh
Message-ID: <20090708181447.29624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-08 18:14:47

Added files:
	test           : t-lvm-init.sh 

Log message:
	Add t-lvm-init.sh - test lvm init routines and error paths.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvm-init.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/test/t-lvm-init.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvm-init.sh
+++ -	2009-07-08 18:14:47.794730000 +0000
@@ -0,0 +1,21 @@
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
+#
+# tests lvm initialization, and especially negative tests of error paths
+#
+
+. ./test-utils.sh
+
+aux prepare_devs 5
+
+# invalid units
+not pvs --config 'global { units = "<" }'
+


