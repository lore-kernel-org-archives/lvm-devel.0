From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Dec 2008 16:15:42 -0000
Subject: LVM2/test lvm-utils.sh t-000-basic.sh
Message-ID: <20081210161542.23563.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-12-10 16:15:41

Modified files:
	test           : lvm-utils.sh t-000-basic.sh 

Log message:
	add simple test for dev node usability (detect devices mounted with nodev)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/lvm-utils.sh	2008/08/21 14:33:48	1.15
+++ LVM2/test/lvm-utils.sh	2008/12/10 16:15:41	1.16
@@ -185,6 +185,4 @@
 EOF
 }
 
-if test $(this_test_) != 000-basic; then
-  init_root_dir_
-fi
+init_root_dir_
--- LVM2/test/t-000-basic.sh	2008/09/29 16:02:49	1.4
+++ LVM2/test/t-000-basic.sh	2008/12/10 16:15:41	1.5
@@ -23,3 +23,8 @@
 # Need mdadm for some pvcreate tests
 # verify mdadm is installed and in path (needed for pvcreate tests) ... is it?
 which mdadm
+
+mknod $G_root_/dev/null c 1 3 ||
+  error "Can't create nodes on filesystem"
+echo >$G_root_/dev/null || 
+  error "Filesystem for tests does not allow using device nodes (check nodev)"


