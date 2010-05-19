From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 12:12:49 -0000
Subject: LVM2/liblvm lvm_base.c
Message-ID: <20100519121249.18039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 12:12:48

Modified files:
	liblvm         : lvm_base.c 

Log message:
	Fix warnings with conversion of uuid.
	
	More cleanup of uuid casting / structures is needed but for now just
	cast like the rest of the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/liblvm/lvm_base.c	2010/05/19 11:53:12	1.17
+++ LVM2/liblvm/lvm_base.c	2010/05/19 12:12:47	1.18
@@ -103,13 +103,13 @@
 const char *lvm_vgname_from_pvid(lvm_t libh, const char *pvid)
 {
 	struct cmd_context *cmd = (struct cmd_context *)libh;
-	char uuid[64] __attribute((aligned(8)));
+	struct id id;
 
-	if (!id_read_format(uuid, pvid)) {
+	if (!id_read_format(&id, pvid)) {
 		log_error(INTERNAL_ERROR "Unable to convert uuid");
 		return NULL;
 	}
-	return find_vgname_from_pvid(cmd, uuid);
+	return find_vgname_from_pvid(cmd, (char *)id.uuid);
 }
 
 const char *lvm_vgname_from_device(lvm_t libh, const char *device)


