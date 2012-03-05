From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Mar 2012 14:45:01 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20120305144501.14967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-05 14:45:00

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use already acquired variable...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:48:13	1.143
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 14:45:00	1.144
@@ -1562,8 +1562,7 @@
 	if (!check_multiple_mangled_name_allowed(mode, name))
 		return_0;
 
-	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf),
-			       dm_get_name_mangling_mode())) < 0) {
+	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf), mode)) < 0) {
 		log_debug("_do_dm_ioctl_unmangle_name: failed to "
 			  "unmangle \"%s\"", name);
 		return 0;


