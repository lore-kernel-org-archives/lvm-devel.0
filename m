From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:36:23 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20081110123623.28004.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:36:23

Modified files:
	test           : test-utils.sh 

Log message:
	Use separate locking directory for each of the tests, as they never share a
	volume group, or physical devices for that matter. Hopefully fixes occasional
	test errors due to locking failures. Patch by jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/test-utils.sh	2008/11/04 14:38:53	1.5
+++ LVM2/test/test-utils.sh	2008/11/10 12:36:23	1.6
@@ -170,6 +170,7 @@
   }
   global {
     library_dir = "$G_root_/lib"
+     locking_dir = "$G_root_/var/lock/lvm"
   }
 EOF
 }


