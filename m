From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:49:01 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/import_vsn1.c
Message-ID: <20111221124901.9219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:49:00

Modified files:
	.              : WHATS_NEW 
	lib/format_text: import_vsn1.c 

Log message:
	Allow empty strings for description and creation_host config fields

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2206&r2=1.2207
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2011/12/20 00:02:19	1.2206
+++ LVM2/WHATS_NEW	2011/12/21 12:49:00	1.2207
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Allow empty strings for description and creation_host config fields.
   Issue deprecation warning when removing last lvm1-format snapshot.
   Reinstate support for snapshot removal with lvm1 format. (2.02.86)
   Add policy based automated repair of RAID logical volumes
--- LVM2/lib/format_text/import_vsn1.c	2011/10/23 16:05:45	1.95
+++ LVM2/lib/format_text/import_vsn1.c	2011/12/21 12:49:00	1.96
@@ -800,7 +800,7 @@
 	int old_suppress;
 
 	old_suppress = log_suppress(1);
-	d = dm_config_find_str(cft->root, "description", "");
+	d = dm_config_find_str_allow_empty(cft->root, "description", "");
 	log_suppress(old_suppress);
 	*desc = dm_pool_strdup(mem, d);
 
@@ -819,7 +819,7 @@
 
 	old_suppress = log_suppress(2);
 	*creation_host = dm_pool_strdup(mem,
-					dm_config_find_str(cft->root,
+					dm_config_find_str_allow_empty(cft->root,
 							"creation_host", ""));
 	log_suppress(old_suppress);
 


