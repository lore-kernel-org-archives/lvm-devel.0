From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:02 -0500
Subject: master - clenaup: use log_warn
Message-ID: <201712041458.vB4Ew21o007180@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76322d3b3e1cf7e118a8207975ae8342de454fa3
Commit:        76322d3b3e1cf7e118a8207975ae8342de454fa3
Parent:        2a01e3d4ca56b13c266629ebb343d1dfb5e9b583
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 13:34:10 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

clenaup: use log_warn

Avoid logging error when function is not failing.
Technically can't really happen ATM anyway.
---
 libdm/libdm-deptree.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6370e88..c976cce 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2705,7 +2705,7 @@ static int _load_node(struct dm_tree_node *dnode)
 	}
 
 	if (!dm_task_no_open_count(dmt))
-		log_error("Failed to disable open_count");
+		log_warn("WARNING: Failed to disable open_count.");
 
 	dm_list_iterate_items(seg, &dnode->props.segs)
 		if (!_emit_segment(dmt, dnode->info.major, dnode->info.minor,
@@ -2713,7 +2713,7 @@ static int _load_node(struct dm_tree_node *dnode)
 			goto_out;
 
 	if (!dm_task_suppress_identical_reload(dmt))
-		log_error("Failed to suppress reload of identical tables.");
+		log_warn("WARNING: Failed to suppress reload of identical tables.");
 
 	if ((r = dm_task_run(dmt))) {
 		r = dm_task_get_info(dmt, &dnode->info);


