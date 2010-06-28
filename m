From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:29:57 -0000
Subject: LVM2/lib/format_text format-text.c layout.h
Message-ID: <20100628202957.12913.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:29:57

Modified files:
	lib/format_text: format-text.c layout.h 

Log message:
	Add text format specific 'rlocn' ignore flag and access functions.
	
	Adding a flag to the 'rlocn' structure in the mda header of the
	text format allows us to flip a bit to ignore an area on disk that
	stores the metadata via the text format specific mda_header.
	This patch defines the flag and access functions to manage the flag.
	Other patches will manage the ignore on a format-independent basis,
	by using a flag in the metadata_area structure.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/format_text/format-text.c	2010/06/22 19:18:27	1.123
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:29:57	1.124
@@ -66,6 +66,19 @@
 	char *desc;		/* Description placed inside file */
 };
 
+int rlocn_is_ignored(const struct raw_locn *rlocn)
+{
+	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
+}
+
+void rlocn_set_ignored(struct raw_locn *rlocn, int value)
+{
+	if (value)
+		rlocn->flags |= RAW_LOCN_IGNORED;
+	else
+		rlocn->flags &= ~RAW_LOCN_IGNORED;
+}
+
 /*
  * NOTE: Currently there can be only one vg per text file.
  */
--- LVM2/lib/format_text/layout.h	2010/06/28 20:29:42	1.10
+++ LVM2/lib/format_text/layout.h	2010/06/28 20:29:57	1.11
@@ -46,6 +46,13 @@
 	struct disk_locn disk_areas_xl[0];	/* Two lists */
 } __attribute__ ((packed));
 
+/*
+ * Ignore this raw location.  This allows us to
+ * ignored metadata areas easily, and thus balance
+ * metadata across VGs with many PVs.
+ */
+#define RAW_LOCN_IGNORED 0x00000001
+
 /* On disk */
 struct raw_locn {
 	uint64_t offset;	/* Offset in bytes to start sector */
@@ -54,6 +61,9 @@
 	uint32_t flags;
 } __attribute__ ((packed));
 
+int rlocn_is_ignored(const struct raw_locn *rlocn);
+void rlocn_set_ignored(struct raw_locn *rlocn, int value);
+
 /* On disk */
 /* Structure size limited to one sector */
 struct mda_header {


