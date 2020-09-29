From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:21 +0000 (GMT)
Subject: master - writecache: archive before modification of metadata
Message-ID: <20200929084521.BFD22384B010@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92c0e8c17f506b551c1b7c0a448d60279e7fdae6
Commit:        92c0e8c17f506b551c1b7c0a448d60279e7fdae6
Parent:        08e838f488415ce6c7df594327c383cdc7c2dcd7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 28 19:17:54 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

writecache: archive before modification of metadata

Archive before we start to modify metadata.
---
 lib/metadata/lv_manip.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 793a86d1f..6a89f1ec0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6506,6 +6506,9 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 
+		if (!archive(vg))
+			return_0;
+
 		if (!lv_detach_writecache_cachevol(lv, 1)) {
 			log_error("Failed to detach writecache from %s", display_lvname(lv));
 			return 0;


