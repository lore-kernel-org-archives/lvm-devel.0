From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 10:36:25 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20101201103625.18539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 10:36:25

Modified files:
	tools          : toollib.c 

Log message:
	Optimize second call to strchr with same parameters
	
	Small optimalization - reusing already known strchr result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215

--- LVM2/tools/toollib.c	2010/11/23 20:39:14	1.214
+++ LVM2/tools/toollib.c	2010/12/01 10:36:25	1.215
@@ -214,6 +214,7 @@
 
 		for (; opt < argc; opt++) {
 			const char *lv_name = argv[opt];
+			const char *tmp_lv_name;
 			char *vgname_def;
 			unsigned dev_dir_found = 0;
 
@@ -246,9 +247,9 @@
 				continue;
 			}
 			lv_name = vgname;
-			if (strchr(vgname, '/')) {
+			if ((tmp_lv_name = strchr(vgname, '/'))) {
 				/* Must be an LV */
-				lv_name = strchr(vgname, '/');
+				lv_name = tmp_lv_name;
 				while (*lv_name == '/')
 					lv_name++;
 				if (!(vgname = extract_vgname(cmd, vgname))) {


