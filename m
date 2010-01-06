From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jan 2010 13:27:08 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/config/d ...
Message-ID: <20100106132708.21880.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-06 13:27:07

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/config     : defaults.h 
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
	Rename mirror_device_fault_policy to mirror_image_fault policy

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1366&r2=1.1367
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/WHATS_NEW	2010/01/06 13:26:21	1.1366
+++ LVM2/WHATS_NEW	2010/01/06 13:27:06	1.1367
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Rename mirror_device_fault_policy to mirror_image_fault policy.
   Remove empty PV devices if lvconvert --repair is using defined policies.
   Use fixed buffer to prevent stack overflow in persistent filter dump.
   Use snapshot metadata usage to determine if a snapshot is empty.
--- LVM2/doc/example.conf	2009/11/30 17:17:11	1.52
+++ LVM2/doc/example.conf	2010/01/06 13:27:07	1.53
@@ -405,7 +405,7 @@
     #            be allocated for the replacement.
 
     mirror_log_fault_policy = "allocate"
-    mirror_device_fault_policy = "remove"
+    mirror_image_fault_policy = "remove"
 }
 
 
--- LVM2/lib/config/defaults.h	2010/01/05 20:56:51	1.56
+++ LVM2/lib/config/defaults.h	2010/01/06 13:27:07	1.57
@@ -46,7 +46,7 @@
 
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
-#define DEFAULT_MIRROR_DEV_FAULT_POLICY "remove"
+#define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_MONITOR 1
--- LVM2/lib/metadata/mirror.c	2010/01/05 21:07:31	1.102
+++ LVM2/lib/metadata/mirror.c	2010/01/06 13:27:07	1.103
@@ -783,9 +783,13 @@
 	if (log_policy)
 		policy = find_config_str(NULL, "activation/mirror_log_fault_policy",
 					 DEFAULT_MIRROR_LOG_FAULT_POLICY);
-	else
-		policy = find_config_str(NULL, "activation/mirror_device_fault_policy",
-					 DEFAULT_MIRROR_DEV_FAULT_POLICY);
+	else {
+		policy = find_config_str(NULL, "activation/mirror_image_fault_policy",
+					 NULL);
+		if (!policy)
+			policy = find_config_str(NULL, "activation/mirror_device_fault_policy",
+						 DEFAULT_MIRROR_IMAGE_FAULT_POLICY);
+	}
 
 	if (!strcmp(policy, "remove"))
 		return MIRROR_REMOVE;
--- LVM2/tools/lvconvert.c	2010/01/06 13:26:21	1.100
+++ LVM2/tools/lvconvert.c	2010/01/06 13:27:07	1.101
@@ -475,6 +475,9 @@
 
 	if (arg_count(cmd, use_policies_ARG)) {
 		leg_policy = find_config_tree_str(cmd,
+					"activation/mirror_image_fault_policy", NULL);
+		if (!leg_policy)
+			leg_policy = find_config_tree_str(cmd,
 					"activation/mirror_device_fault_policy",
 					DEFAULT_MIRROR_DEVICE_FAULT_POLICY);
 		log_policy = find_config_tree_str(cmd,


