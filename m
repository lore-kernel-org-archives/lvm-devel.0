From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Nov 2010 09:43:20 -0000
Subject: LVM2 ./WHATS_NEW tools/dmsetup.c
Message-ID: <20101124094320.20204.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-24 09:43:19

Modified files:
	.              : WHATS_NEW 
	tools          : dmsetup.c 

Log message:
	Fix memory leak in error path
	
	Release allocated path buffer in error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1807&r2=1.1808
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW	2010/11/24 09:34:34	1.1807
+++ LVM2/WHATS_NEW	2010/11/24 09:43:18	1.1808
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix memory leak in error path of parse_loop_device_name() from dmsetup.
   Fix missing dlclose in _init_formats() error path from init_format call.
   Fix missing fclose for _umount() in dmeventd snapshot plugin.
   Fix out-of-scope variable usage in process_each_lv().
--- LVM2/tools/dmsetup.c	2010/10/25 13:36:57	1.147
+++ LVM2/tools/dmsetup.c	2010/11/24 09:43:18	1.148
@@ -2904,6 +2904,7 @@
 	return buf;
 
 error:
+	dm_free(buf);
 	return NULL;
 }
 


