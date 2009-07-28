From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 14:12:30 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090728141230.18208.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 14:12:30

Modified files:
	test/api       : test.c 

Log message:
	Update interactive unit test - fix silly vg_close error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/test/api/test.c	2009/07/28 13:49:28	1.22
+++ LVM2/test/api/test.c	2009/07/28 14:12:29	1.23
@@ -329,11 +329,11 @@
 {
 	vg_t *vg=NULL;
 
-	while((vg = dm_hash_lookup(_vgname_hash, vgname))) {
+	if ((vg = dm_hash_lookup(_vgname_hash, vgname))) {
 		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
 		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
 	}
-	while(vg && (vg = dm_hash_lookup(_vgid_hash, vgname))) {
+	if (!vg && (vg = dm_hash_lookup(_vgid_hash, vgname))) {
 		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
 		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
 	}


