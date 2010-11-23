From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 15:28:55 -0000
Subject: LVM2 lib/activate/fs.c ./WHATS_NEW
Message-ID: <20101123152855.12264.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 15:28:55

Modified files:
	lib/activate   : fs.c 
	.              : WHATS_NEW 

Log message:
	Add missing  closedir() - fixes resource leak

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1802&r2=1.1803

--- LVM2/lib/activate/fs.c	2010/01/11 15:40:03	1.51
+++ LVM2/lib/activate/fs.c	2010/11/23 15:28:54	1.52
@@ -105,6 +105,9 @@
 				log_sys_error("unlink", path);
 		}
 	}
+
+	if (closedir(d))
+		log_sys_error("closedir", dir);
 }
 
 static int _mk_link(const char *dev_dir, const char *vg_name,
--- LVM2/WHATS_NEW	2010/11/23 01:55:53	1.1802
+++ LVM2/WHATS_NEW	2010/11/23 15:28:55	1.1803
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix resource leak in _rm_blks().
   Suppress 'No PV label' message when removing several PVs without mdas.
   Fix default /etc/lvm permissions to be 0755. (2.02.66)
 


