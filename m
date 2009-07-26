From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:32:27 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023227.16225.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:32:27

Modified files:
	tools          : lvcreate.c 

Log message:
	Comment lvcreate_params struct.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204

--- LVM2/tools/lvcreate.c	2009/07/26 02:32:00	1.203
+++ LVM2/tools/lvcreate.c	2009/07/26 02:32:26	1.204
@@ -26,39 +26,39 @@
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
-	int snapshot;
-	int zero;
-	int major;
-	int minor;
-	int corelog;
-	int nosync;
+	int snapshot; /* snap */
+	int zero; /* all */
+	int major; /* all */
+	int minor; /* all */
+	int corelog; /* mirror */
+	int nosync; /* mirror */
+
+	char *origin; /* snap */
+	const char *vg_name; /* all */
+	const char *lv_name; /* all */
+
+	uint32_t stripes; /* striped */
+	uint32_t stripe_size; /* striped */
+	uint32_t chunk_size; /* snapshot */
+	uint32_t region_size; /* mirror */
 
-	char *origin;
-	const char *vg_name;
-	const char *lv_name;
-
-	uint32_t stripes;
-	uint32_t stripe_size;
-	uint32_t chunk_size;
-	uint32_t region_size;
+	uint32_t mirrors; /* mirror */
 
-	uint32_t mirrors;
-
-	const struct segment_type *segtype;
+	const struct segment_type *segtype; /* all */
 
 	/* size */
-	uint32_t extents;
-	uint32_t voriginextents;
-	uint64_t voriginsize;
-	struct dm_list *pvh;
-
-	uint32_t permission;
-	uint32_t read_ahead;
-	alloc_policy_t alloc;
-
-	int pv_count;
-	char **pvs;
-	const char *tag;
+	uint32_t extents; /* all */
+	uint32_t voriginextents; /* snapshot */
+	uint64_t voriginsize; /* snapshot */
+	struct dm_list *pvh; /* all */
+
+	uint32_t permission; /* all */
+	uint32_t read_ahead; /* all */
+	alloc_policy_t alloc; /* all */
+
+	int pv_count; /* all; redundant? */
+	char **pvs; /* all; redundant? */
+	const char *tag; /* all */
 };
 
 static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,


