From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 25 Oct 2011 13:17:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20111025131705.14031.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-25 13:17:05

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Disallow 'mirrored' log for cluster mirrors.
	
	Git commit ID 0864378250956c310cb81608978d091fcdcc97d8 was meant to disallow
	'mirrored' logs for cluster mirrors.  However, when add_mirror_log is used
	to create the log (as is now the case when using 'lvcreate' or converting only
	the log) the check is bypassed.
	
	This patch adds the check to add_mirror_log.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2171&r2=1.2172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174

--- LVM2/WHATS_NEW	2011/10/24 10:24:39	1.2171
+++ LVM2/WHATS_NEW	2011/10/25 13:17:04	1.2172
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix regression that allowed mirrored logs for cluster mirrors.
   Don't print char type[8] as a plain string in pvck PV type.
   Use vg memory pool implicitely for vg read.
   Always use vg memory pool for allocated lv segment.
--- LVM2/lib/metadata/mirror.c	2011/10/06 14:55:40	1.173
+++ LVM2/lib/metadata/mirror.c	2011/10/25 13:17:04	1.174
@@ -1898,6 +1898,11 @@
 	unsigned old_log_count;
 	int r = 0;
 
+	if (vg_is_clustered(lv->vg) && (log_count > 1)) {
+		log_error("Log type, \"mirrored\", is unavailable to cluster mirrors");
+		return 0;
+	}
+
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;


