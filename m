From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:23:13 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/device/dev-cache.c lib ...
Message-ID: <20101220132313.13490.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:23:12

Modified files:
	.              : WHATS_NEW_DM 
	lib/device     : dev-cache.c 
	libdm          : libdevmapper.h 
	libdm/regex    : matcher.c 

Log message:
	Use const char* const * for dm_regex_create()
	
	Change API interface to accept even completely const array patterns.
	
	This should present no change for libdm users and allows to pass
	pattern arrays without cast to const char **.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.431&r2=1.432
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW_DM	2010/12/13 10:43:56	1.431
+++ LVM2/WHATS_NEW_DM	2010/12/20 13:23:11	1.432
@@ -1,5 +1,6 @@
 Version 1.02.60 -
 ===================================
+  Change dm_regex_create() API to accept const char * const *patterns.
   Add new dm_prepare_selinux_context fn to libdevmapper and use it throughout.
   Detect existence of new SELinux selabel interface during configure.
 
--- LVM2/lib/device/dev-cache.c	2010/12/20 13:12:56	1.61
+++ LVM2/lib/device/dev-cache.c	2010/12/20 13:23:11	1.62
@@ -543,7 +543,7 @@
 	const struct config_node *cn;
 	const struct config_value *v;
 	struct dm_pool *scratch = NULL;
-	char **regex;
+	const char **regex;
 	unsigned count = 0;
 	int i, r = 0;
 
@@ -583,7 +583,7 @@
 	}
 
 	if (!(_cache.preferred_names_matcher =
-		dm_regex_create(_cache.mem,(const char **) regex, count))) {
+		dm_regex_create(_cache.mem, regex, count))) {
 		log_error("Preferred device name pattern matcher creation failed.");
 		goto out;
 	}
--- LVM2/libdm/libdevmapper.h	2010/12/13 10:43:58	1.129
+++ LVM2/libdm/libdevmapper.h	2010/12/20 13:23:12	1.130
@@ -1020,7 +1020,7 @@
  * Initialise an array of num patterns for matching.
  * Uses memory from mem.
  */
-struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
+struct dm_regex *dm_regex_create(struct dm_pool *mem, const char * const *patterns,
 				 unsigned num_patterns);
 
 /*
--- LVM2/libdm/regex/matcher.c	2010/11/29 14:25:13	1.15
+++ LVM2/libdm/regex/matcher.c	2010/12/20 13:23:12	1.16
@@ -310,7 +310,7 @@
         }
 }
 
-struct dm_regex *dm_regex_create(struct dm_pool *mem, const char **patterns,
+struct dm_regex *dm_regex_create(struct dm_pool *mem, const char * const *patterns,
 				 unsigned num_patterns)
 {
 	char *all, *ptr;


