From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:37 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - lv_raid_split: add clustered vg check
Message-ID: <20150131141037.25941601E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86c0cd36df46cba666cc5b191f3d8c0f71f1ef2c
Commit:        86c0cd36df46cba666cc5b191f3d8c0f71f1ef2c
Parent:        291486655d75f5c1f92364a43b11f41b0faeb38f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jan 28 14:22:35 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jan 28 14:22:35 2015 +0100

lv_raid_split: add clustered vg check

---
 lib/metadata/raid_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d60c708..3327935 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1453,6 +1453,12 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
+	if (vg_is_clustered(lv->vg) && !lv_is_active_exclusive_locally(lv)) {
+		log_error("%s/%s must be active exclusive locally to"
+			  " perform this operation.", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	if (find_lv_in_vg(lv->vg, split_name)) {
 		log_error("Logical Volume \"%s\" already exists in %s",
 			  split_name, lv->vg->name);


