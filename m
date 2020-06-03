From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Jun 2020 17:40:01 +0000 (GMT)
Subject: master - improve info about vgck updatemetadata
Message-ID: <20200603174001.05B533840C1C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa9eb76a5dc8d76a1f06a44337f909c75df1fee9
Commit:        fa9eb76a5dc8d76a1f06a44337f909c75df1fee9
Parent:        b59127a8386a407407a0361b9bcad028ce31a733
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 3 12:38:27 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 3 12:38:27 2020 -0500

improve info about vgck updatemetadata

Add man page info about this option, and add log messages
pointing to this option.
---
 lib/cache/lvmcache.c    |  4 ++++
 lib/metadata/metadata.c |  4 +++-
 tools/args.h            | 11 ++++++++++-
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6cb5ff0d8..b1d05fb07 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -84,6 +84,7 @@ static DM_LIST_INIT(_unused_duplicates);
 static DM_LIST_INIT(_prev_unused_duplicate_devs);
 static int _vgs_locked = 0;
 static int _found_duplicate_vgnames = 0;
+static int _outdated_warning = 0;
 
 int lvmcache_init(struct cmd_context *cmd)
 {
@@ -1776,6 +1777,9 @@ int lvmcache_update_vg_from_read(struct volume_group *vg, unsigned precommitted)
 		log_warn("WARNING: outdated PV %s seqno %u has been removed in current VG %s seqno %u.",
 			 dev_name(info->dev), info->summary_seqno, vg->name, vginfo->seqno);
 
+		if (!_outdated_warning++)
+			log_warn("See vgck --updatemetadata to clear outdated metadata.");
+
 		_drop_vginfo(info, vginfo); /* remove from vginfo->infos */
 		dm_list_add(&vginfo->outdated_infos, &info->list);
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4b8dce902..c0d42066d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4875,8 +4875,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 	}
 
-	if (found_old_metadata)
+	if (found_old_metadata) {
 		log_warn("WARNING: Inconsistent metadata found for VG %s.", vgname);
+		log_warn("See vgck --updatemetadata to correct inconsistency.");
+	}
 
 	vg = NULL;
 
diff --git a/tools/args.h b/tools/args.h
index d1f604b0c..5fae21abb 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1428,7 +1428,16 @@ arg(thin_ARG, 'T', "thin", 0, 0, 0,
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n")
 
 arg(updatemetadata_ARG, '\0', "updatemetadata", 0, 0, 0,
-    "Update VG metadata to correct problems.\n")
+    "Update VG metadata to correct problems.\n"
+    "If VG metadata was updated while a PV was missing, and the PV\n"
+    "reappears with an old version of metadata, then this option\n"
+    "(or any other command that writes metadata) will update the\n"
+    "metadata on the previously missing PV. If a PV was removed\n"
+    "from a VG while it was missing, and the PV reappears, using\n"
+    "this option will clear the outdated metadata from the previously\n"
+    "missing PV. If metadata text is damaged on one PV, using this\n"
+    "option will replace the damaged metadata text. For more severe\n"
+    "damage, e.g. with headers, see \\fBpvck\\fP(8).\n")
 
 arg(uuid_ARG, 'u', "uuid", 0, 0, 0,
     "#pvchange\n"


