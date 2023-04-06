From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu,  6 Apr 2023 11:47:31 +0000 (GMT)
Subject: main - integrity: hide creation of internal LVs
Message-ID: <20230406114731.DF46D385842E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51117b579350e2e44e3dae72642010a18b8506b1
Commit:        51117b579350e2e44e3dae72642010a18b8506b1
Parent:        390ff5be2fd9dda47f2bfd2db96de64acc925002
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 25 20:29:05 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 6 11:06:04 2023 +0200

integrity: hide creation of internal LVs

Creation of 'hidden' local LVs should be visible only in
verbose mode (-v) when creating a raid LV with integrity.
---
 lib/metadata/integrity_manip.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index e9895b836..ffb869b08 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -99,6 +99,7 @@ static int _lv_create_integrity_metadata(struct cmd_context *cmd,
 		.read_ahead = DM_READ_AHEAD_NONE,
 		.stripes = 1,
 		.vg_name = vg->name,
+		.temporary = 1,
 		.zero = 0,
 		.wipe_signatures = 0,
 		.suppress_zero_warn = 1,
@@ -118,8 +119,8 @@ static int _lv_create_integrity_metadata(struct cmd_context *cmd,
 	meta_sectors = meta_bytes / 512;
 	lp_meta.extents = meta_sectors / vg->extent_size;
 
-	log_print_unless_silent("Creating integrity metadata LV %s with size %s.",
-		  metaname, display_size(cmd, meta_sectors));
+	log_verbose("Creating integrity metadata LV %s with size %s.",
+		    metaname, display_size(cmd, meta_sectors));
 
 	dm_list_init(&lp_meta.tags);
 

