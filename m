From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:36:07 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20111017143607.14163.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:36:06

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use zalloc for malloc,memset

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/libdm/ioctl/libdm-iface.c	2011/09/23 17:16:28	1.123
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/10/17 14:36:06	1.124
@@ -852,7 +852,7 @@
 struct target *create_target(uint64_t start, uint64_t len, const char *type,
 			     const char *params)
 {
-	struct target *t = dm_malloc(sizeof(*t));
+	struct target *t = dm_zalloc(sizeof(*t));
 
 	if (!t) {
 		log_error("create_target: malloc(%" PRIsize_t ") failed",
@@ -860,8 +860,6 @@
 		return NULL;
 	}
 
-	memset(t, 0, sizeof(*t));
-
 	if (!(t->params = dm_strdup(params))) {
 		log_error("create_target: strdup(params) failed");
 		goto bad;


