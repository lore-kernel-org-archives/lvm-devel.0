From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Nov 2009 12:33:28 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h udev/ ...
Message-ID: <20091113123328.23060.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-11-13 12:33:27

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 
	udev           : 13-dm-disk.rules 

Log message:
	Remove 'last_rule' from udev rules.
	
	'last_rule' option has been removed from udev (version >= 147).
	
	From now on, we require foreign rules to check and honor
	ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG} instead. Foreign
	rules should be skipped totally when this flag is set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.312&r2=1.313
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW_DM	2009/11/06 00:43:08	1.312
+++ LVM2/WHATS_NEW_DM	2009/11/13 12:33:27	1.313
@@ -1,5 +1,6 @@
 Version 1.02.40 - 
 ===================================
+  Remove 'last_rule' from udev rules: honor ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}.
   Add dmsetup --inactive support.
   Add dm_task_query_inactive_table to libdevmapper for kernel driver >= 4.16.
   Fix hash lookup segfault when keys compared are different lengths.
--- LVM2/libdm/libdevmapper.h	2009/11/06 00:43:08	1.101
+++ LVM2/libdm/libdevmapper.h	2009/11/13 12:33:27	1.102
@@ -1058,9 +1058,9 @@
 /*
  * DM_UDEV_DISABLE_OTHER_RULES_FLAG is set in case we need to disable
  * all the other rules that are not general device-mapper nor subsystem
- * related (the rules belong to other software or packages). Use this
- * flag with care since it will cutoff the rule processing after the
- * last device-mapper/subsytem rule is applied.
+ * related (the rules belong to other software or packages). All foreign
+ * rules should check this flag directly and they should ignore further
+ * rule processing for such event.
  */
 #define DM_UDEV_DISABLE_OTHER_RULES_FLAG 0x0008
 /*
--- LVM2/udev/13-dm-disk.rules	2009/10/26 22:42:07	1.4
+++ LVM2/udev/13-dm-disk.rules	2009/11/13 12:33:27	1.5
@@ -10,27 +10,18 @@
 # suspended.
 
 # "add" event is processed on coldplug only!
-ACTION!="add|change", GOTO="dm_other"
-ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_other"
-ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_other"
+ACTION!="add|change", GOTO="dm_end"
+ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
+ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_end"
 
 SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
 ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"
 
-ENV{DM_SUSPENDED}=="1", GOTO="dm_other"
+ENV{DM_SUSPENDED}=="1", GOTO="dm_end"
 
 IMPORT{program}="$env{DM_SBIN_PATH}/blkid -o udev -p $tempnode"
 ENV{DM_UDEV_LOW_PRIORITY_FLAG}=="1", OPTIONS="link_priority=-100"
 ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{ID_FS_UUID_ENC}=="?*", SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
-# Cutoff all subsequent rules if instructed by a flag.
-# This flag should be used in well-founded situations only to prevent
-# any problems that could arise when processing this event further by
-# foreign rules (various temporary and hidden devices mostly).
-LABEL="dm_other"
-ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}!="1", GOTO="dm_end"
-ENV{DM_COOKIE}=="?*", RUN+="$env{DM_SBIN_PATH}/dmsetup udevcomplete $env{DM_COOKIE}"
-OPTIONS+="last_rule"
-
 LABEL="dm_end"


