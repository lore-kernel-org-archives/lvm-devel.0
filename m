From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Apr 2011 17:03:39 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgimportclone.sh
Message-ID: <20110421170339.31530.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2011-04-21 17:03:39

Modified files:
	.              : WHATS_NEW 
Added files:
	test           : t-vgimportclone.sh 

Log message:
	Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
	
	Related to rhbz 697959.
	
	This test fails prior to these two commits:
	commit af112eb2c9a62c5d794df920218bd3ee291d5b25
	Author: Zdenek Kabelac <zkabelac@redhat.com>
	Date:   Thu Apr 21 13:15:26 2011 +0000
	
	Skip check for NULL before dm_free
	
	dm_free makes this test itself.
	
	commit 91419c3e86bf9666aab2aa631faae1ba73e8d745
	Author: Zdenek Kabelac <zkabelac@redhat.com>
	Date:   Thu Apr 21 13:13:40 2011 +0000
	
	Fix use of released vgname and vgid

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgimportclone.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1973&r2=1.1974

/cvs/lvm2/LVM2/test/t-vgimportclone.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgimportclone.sh
+++ -	2011-04-21 17:03:39.444919000 +0000
@@ -0,0 +1,35 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
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
+aux prepare_devs 2
+
+pvcreate $dev1 $dev2
+vgcreate $vg1 $dev1
+lvcreate -l100%FREE -n $lv1 $vg1
+
+# Clone the LUN
+dd if=$dev1 of=$dev2
+
+# Verify pvs works on each device to give us vgname
+pvs --noheadings -o vg_name $dev1 1>err
+grep $vg1 err
+pvs --noheadings -o vg_name $dev2 1>err
+grep $vg1 err
+
+# Import the cloned PV to a new VG
+vgimportclone --basevgname $vg2 $dev2
+
+# Verify we can activate / deactivate the LV from both VGs
+lvchange -ay $vg1/$lv1
+lvchange -ay $vg2/$lv1
+vgchange -an $vg1
+vgchange -an $vg2
--- LVM2/WHATS_NEW	2011/04/21 13:13:40	1.1973
+++ LVM2/WHATS_NEW	2011/04/21 17:03:38	1.1974
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add nightly test for vgimportclone and querying of vgnames with duplicate pvs.
   Fix use of released memory when duplicate PV is found.
   Add "devices/issue_discards" to lvm.conf.
   Issue discards on lvremove, lvreduce, etc if enabled and supported.


