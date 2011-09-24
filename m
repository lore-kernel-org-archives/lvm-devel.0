From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Sep 2011 11:47:54 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20110924114754.22576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-24 11:47:53

Modified files:
	libdm          : libdm-common.c 

Log message:
	readlink does not append a null byte to the output string!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/libdm/libdm-common.c	2011/09/22 17:23:36	1.126
+++ LVM2/libdm/libdm-common.c	2011/09/24 11:47:53	1.127
@@ -1145,6 +1145,7 @@
 		log_sys_error("readlink", sysfs_path);
 		return 0;
 	}
+	temp_path[size] = '\0';
 
 	if (!(kernel_dev_name = strrchr(temp_path, '/'))) {
 		log_error("Could not locate device kernel name in sysfs path %s", temp_path);


