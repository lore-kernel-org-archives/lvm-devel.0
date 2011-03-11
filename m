From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Mar 2011 22:25:36 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110311222536.12369.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-11 22:25:36

Modified files:
	scripts        : gdbinit 

Log message:
	lv_status_r now prints out status of attached log LVs
	
	(Print layout could be nicer... :(

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/gdbinit	2011/03/11 22:16:38	1.3
+++ LVM2/scripts/gdbinit	2011/03/11 22:25:36	1.4
@@ -198,10 +198,11 @@
 end
 
 define lv_status
-	set $_lv=(struct logical_volume *)$arg0
+	# Use __lv because we don't want to overwrite higher functions
+	set $__lv = (struct logical_volume *)$arg0
 
-	printf "%s->status:", $_lv->name
-	__status $_lv
+	printf "%s->status:", $__lv->name
+	__status $__lv
 	printf "\n"
 end
 
@@ -371,6 +372,10 @@
 			__seg_item $_lv $_seg $_area_index
 			__lv_status_r $_lv
 		else
+			if ($_seg->log_lv)
+				printf "[LOG OF %s] ", $_lv->name
+				lv_status $_seg->log_lv
+			end
 			__get_only_segment_using_this_lv $_seg $_lv
 			if ($_seg)
 				__lv_status_r $_lv $_seg


