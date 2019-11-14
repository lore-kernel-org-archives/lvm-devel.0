From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:17 -0500
Subject: master - cov: check for NULL
Message-ID: <62050.119111412071300931@us-mta-105.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82e6b820b84512ffb9f124c5d450c1036e7dd843
Commit:        82e6b820b84512ffb9f124c5d450c1036e7dd843
Parent:        43f149526d5074dbc6deeaca38e30d02611eadf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:04:33 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: check for NULL

Since we check for NULL pointers earlier we need
to be consistent across function - since the NULL
would applies across whole function.

When dropping 'mda' check - we are actually
already dereferencing it before - so it can't
be NULL at that places (and it's validated
before entering  _read_mda_header_and_metadata).
---
 lib/format_text/format-text.c |    2 +-
 lib/format_text/text_label.c  |    6 ++----
 tools/pvscan.c                |    2 +-
 tools/toollib.c               |    3 ++-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 894a710..f3536e7 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -341,7 +341,7 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	 * Don't try to check existing metadata
 	 * if given vgname is an empty string.
 	 */
-	if (!*vgname)
+	if (!vgname || !*vgname)
 		return rlocn;
 
 	/*
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 246fb7b..cb60c15 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -332,14 +332,12 @@ static int _read_mda_header_and_metadata(const struct format_type *fmt,
 		log_warn("WARNING: bad metadata header on %s at %llu.",
 			 dev_name(mdac->area.dev),
 			 (unsigned long long)mdac->area.start);
-		if (mda)
-			mda->header_start = mdac->area.start;
+		mda->header_start = mdac->area.start;
 		*bad_fields |= BAD_MDA_HEADER;
 		return 0;
 	}
 
-	if (mda)
-		mda->header_start = mdah->start;
+	mda->header_start = mdah->start;
 
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 96ef438..312a633 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -420,7 +420,7 @@ check_duplicate:
 		log_error("pvscan[%d] PV %s is duplicate for PVID %s on %d:%d and %d:%d.",
 			  getpid(), dev_name(dev), dev->pvid, major, minor, file_major, file_minor);
 
-	if (file_vgname[0] && strcmp(file_vgname, vgname))
+	if (file_vgname[0] && vgname && strcmp(file_vgname, vgname))
 		log_error("pvscan[%d] PV %s has unexpected VG %s vs %s.",
 			  getpid(), dev_name(dev), vgname, file_vgname);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index bb97e15..ee2419b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4284,7 +4284,8 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		/*
 		 * When processing only specific PVs, we can quit once they've all been found.
 	 	 */
-		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
+		if (!process_all_pvs && dm_list_empty(arg_tags) &&
+		    (!arg_devices || dm_list_empty(arg_devices)))
 			break;
 		log_set_report_object_name_and_id(NULL, NULL);
 	}



