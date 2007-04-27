From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Apr 2007 18:52:07 -0000
Subject: LVM2 ./WHATS_NEW include/.symlinks lib/Makefil ...
Message-ID: <20070427185207.19845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-27 19:52:06

Modified files:
	.              : WHATS_NEW 
	include        : .symlinks 
	lib            : Makefile.in 
	lib/device     : dev-cache.c 
	lib/filters    : filter-regex.c 
Removed files:
	lib/regex      : matcher.c matcher.h parse_rx.c parse_rx.h 
	                 ttree.c ttree.h 

Log message:
	Move regex functions into libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.608&r2=1.609
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/matcher.c.diff?cvsroot=lvm2&r1=1.16&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/matcher.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.10&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/parse_rx.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/ttree.c.diff?cvsroot=lvm2&r1=1.11&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/regex/ttree.h.diff?cvsroot=lvm2&r1=1.4&r2=NONE

--- LVM2/WHATS_NEW	2007/04/27 17:46:15	1.608
+++ LVM2/WHATS_NEW	2007/04/27 18:52:05	1.609
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Move regex functions into libdevmapper.
   Change some #include lines to search only standard system directories.
   Add devices/preferred_names config regex list for displayed device names.
   Free a temporary dir string in fcntl_lock_file() after use.
--- LVM2/include/.symlinks	2006/08/17 18:23:42	1.43
+++ LVM2/include/.symlinks	2007/04/27 18:52:05	1.44
@@ -43,7 +43,6 @@
 ../lib/misc/lvm-string.h
 ../lib/misc/lvm-wrappers.h
 ../lib/misc/sharedlib.h
-../lib/regex/matcher.h
 ../lib/report/report.h
 ../lib/uuid/uuid.h
 ../po/pogen.h
--- LVM2/lib/Makefile.in	2006/09/30 20:02:02	1.80
+++ LVM2/lib/Makefile.in	2007/04/27 18:52:05	1.81
@@ -81,9 +81,6 @@
 	misc/lvm-wrappers.c \
 	misc/timestamp.c \
 	mm/memlock.c \
-	regex/matcher.c \
-	regex/parse_rx.c \
-	regex/ttree.c \
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
--- LVM2/lib/device/dev-cache.c	2007/04/26 17:14:57	1.47
+++ LVM2/lib/device/dev-cache.c	2007/04/27 18:52:05	1.48
@@ -19,7 +19,6 @@
 #include "btree.h"
 #include "filter.h"
 #include "filter-persistent.h"
-#include "matcher.h"
 #include "toolcontext.h"
 
 #include <unistd.h>
@@ -40,7 +39,7 @@
 	struct dm_pool *mem;
 	struct dm_hash_table *names;
 	struct btree *devices;
-	struct matcher *preferred_names_matcher;
+	struct dm_regex *preferred_names_matcher;
 
 	int has_scanned;
 	struct list dirs;
@@ -159,8 +158,8 @@
 	 * FIXME Better to compare patterns one-at-a-time against all names.
 	 */
 	if (_cache.preferred_names_matcher) {
-		m0 = matcher_run(_cache.preferred_names_matcher, path0);
-		m1 = matcher_run(_cache.preferred_names_matcher, path1);
+		m0 = dm_regex_match(_cache.preferred_names_matcher, path0);
+		m1 = dm_regex_match(_cache.preferred_names_matcher, path1);
 
 		if (m0 != m1) {
 			if (m0 < 0)
@@ -526,7 +525,7 @@
 	}
 
 	if (!(_cache.preferred_names_matcher =
-		matcher_create(_cache.mem,(const char **) regex, count))) {
+		dm_regex_create(_cache.mem,(const char **) regex, count))) {
 		log_error("Preferred device name pattern matcher creation failed.");
 		goto out;
 	}
--- LVM2/lib/filters/filter-regex.c	2007/04/26 16:44:58	1.21
+++ LVM2/lib/filters/filter-regex.c	2007/04/27 18:52:05	1.22
@@ -15,13 +15,12 @@
 
 #include "lib.h"
 #include "filter-regex.h"
-#include "matcher.h"
 #include "device.h"
 
 struct rfilter {
 	struct dm_pool *mem;
 	dm_bitset_t accept;
-	struct matcher *engine;
+	struct dm_regex *engine;
 };
 
 static int _extract_pattern(struct dm_pool *mem, const char *pat,
@@ -98,7 +97,7 @@
 	unsigned count = 0;
 	int i, r = 0;
 
-	if (!(scratch = dm_pool_create("filter matcher", 1024)))
+	if (!(scratch = dm_pool_create("filter dm_regex", 1024)))
 		return_0;
 
 	/*
@@ -138,8 +137,8 @@
 	/*
 	 * build the matcher.
 	 */
-	if (!(rf->engine = matcher_create(rf->mem, (const char **) regex,
-					  count)))
+	if (!(rf->engine = dm_regex_create(rf->mem, (const char **) regex,
+					   count)))
 		stack;
 	r = 1;
 
@@ -155,7 +154,7 @@
 	struct str_list *sl;
 
 	list_iterate_items(sl, &dev->aliases) {
-		m = matcher_run(rf->engine, sl->str);
+		m = dm_regex_match(rf->engine, sl->str);
 
 		if (m >= 0) {
 			if (dm_bit(rf->accept, m)) {


