From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jan 2012 12:29:16 -0000
Subject: LVM2/test/unit config_t.c
Message-ID: <20120109122916.30230.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-09 12:29:15

Modified files:
	test/unit      : config_t.c 

Log message:
	Minor oldstyle warning update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/config_t.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/unit/config_t.c	2011/12/18 23:56:36	1.4
+++ LVM2/test/unit/config_t.c	2012/01/09 12:29:15	1.5
@@ -131,7 +131,7 @@
 	dm_config_destroy(tree);
 }
 
-static void test_cascade()
+static void test_cascade(void)
 {
 	struct dm_config_tree *t1 = dm_config_from_string(conf),
 		              *t2 = dm_config_from_string(overlay),


