From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:42:33 +0000 (UTC)
Subject: master - vgrename: run fullscan
Message-ID: <20131008114233.671A560F40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30746f31dd1db63e0c83e6f8c7ae65dab3f69a4b
Commit:        30746f31dd1db63e0c83e6f8c7ae65dab3f69a4b
Parent:        4806f38d703c2d7cd01e0adc49505ccb7d010a17
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 11:15:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 13:39:11 2013 +0200

vgrename: run fullscan

For vgrename run full scan so the command is able to properly
detect name collision.
---
 WHATS_NEW        |    1 +
 tools/vgrename.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5b35890..93a156a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.104
 ===================================
   Improve message when unable to change discards setting on active thin pool.
+  Run full scan before vgrename operation to avoid any cache name collision.
 
 Version 2.02.103 - 4th October 2013
 ===================================
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 154a6f3..b5e778f 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -83,6 +83,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
 		stack;
 
+	lvmcache_label_scan(cmd, 2);
+
 	/* Avoid duplicates */
 	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");


