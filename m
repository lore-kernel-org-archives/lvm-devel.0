From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Dec 2013 15:53:35 +0000 (UTC)
Subject: master - config: fix metadata/disk_areas config setting registration
Message-ID: <20131213155335.29079610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d443bfac216a3eedcd752d532f6f90a339681b44
Commit:        d443bfac216a3eedcd752d532f6f90a339681b44
Parent:        32080c4ff748e4afbeacf9dbc4a98bfea658a392
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 13 16:43:01 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 13 16:52:51 2013 +0100

config: fix metadata/disk_areas config setting registration

The metadata/disk_areas setting was incorrectly registered as
"string" configuration option but it's a section where each area
is defined in its own subsection with "start_sector", "size" and "id"
setting.

This setting is not officialy supported, it's undocumented and it's
used solely for debugging.

Note: At this moment, it does not seem to be working with lvmetad!
---
 lib/config/config_settings.h  |    7 ++++++-
 lib/format_text/format-text.c |    3 ++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 0e0e469..1546b3f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -205,7 +205,12 @@ cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_ADV
 cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL)
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL)
 cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
-cfg(metadata_disk_areas_CFG, "disk_areas", metadata_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
+
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED, vsn(1, 0, 0), NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED, vsn(1, 0, 0), NULL)
+cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
+cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL)
 cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index eb5c9e9..22d772f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2458,7 +2458,8 @@ struct format_type *create_text_format(struct cmd_context *cmd)
 		}
 	}
 
-	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG, NULL))) {
+	if ((cn = find_config_tree_node(cmd, metadata_disk_areas_CFG_SUBSECTION, NULL))) {
+		/* FIXME: disk_areas do not work with lvmetad - the "id" can't be found. */
 		for (cn = cn->child; cn; cn = cn->sib) {
 			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
 				goto_bad;


