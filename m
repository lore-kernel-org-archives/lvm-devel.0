From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 10 Jan 2010 20:44:10 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100110204410.24606.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-10 20:44:09

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	remove unused variable 'i' that was recently introduced in lv_add_segment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194

--- LVM2/lib/metadata/lv_manip.c	2010/01/08 23:06:36	1.193
+++ LVM2/lib/metadata/lv_manip.c	2010/01/10 20:44:09	1.194
@@ -1390,7 +1390,6 @@
 		   uint32_t region_size,
 		   struct logical_volume *log_lv)
 {
-	int i;
 	struct dm_list *aa_list;
 
 	/*


