From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 10:33:57 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/disk-rep.c
Message-ID: <20101201103357.19576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 10:33:56

Modified files:
	.              : WHATS_NEW 
	lib/format1    : disk-rep.c 

Log message:
	Fallback to full rescan for missing device
	
	Fix bug when NULL could have been passsed as 'data'
	to _add_pv_to_list() if 'dev' is NULL.
	
	Now it fallbacks to complete scan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1819&r2=1.1820
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2010/11/30 23:03:35	1.1819
+++ LVM2/WHATS_NEW	2010/12/01 10:33:55	1.1820
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Do a full rescan if some device is missing in read_pvs_in_vg().
   Avoid misleading warnings in vgextend --restoremissing in certain cases.
   Add error path stack traces for _process_mapper_dir(), _create_and_load_v4().
   Add missing test for failed pool allocation in write_config_node().
--- LVM2/lib/format1/disk-rep.c	2010/09/30 21:06:51	1.82
+++ LVM2/lib/format1/disk-rep.c	2010/12/01 10:33:56	1.83
@@ -471,7 +471,7 @@
 	    vginfo->infos.n) {
 		dm_list_iterate_items(info, &vginfo->infos) {
 			dev = info->dev;
-			if (dev && !(data = read_disk(fmt, dev, mem, vg_name)))
+			if (!dev || !(data = read_disk(fmt, dev, mem, vg_name)))
 				break;
 			_add_pv_to_list(head, data);
 		}


