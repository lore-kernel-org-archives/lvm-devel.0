From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Jun 2018 15:15:56 -0400
Subject: 2018-06-01-stable - clvmd: fix leak of saved_vg struct
Message-ID: <201806181915.w5IJFubD005660@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76075ff55d7d23731b91929ef992fe6bdd32a964
Commit:        76075ff55d7d23731b91929ef992fe6bdd32a964
Parent:        bfb904af1cb0a48a4ac44eb72179f628fda4fd03
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 18 14:10:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 18 14:14:38 2018 -0500

clvmd: fix leak of saved_vg struct

Commit c016b573ee32f "clvmd: separate saved_vg from vginfo"
created a separate hash table for the saved_vg structs.
The vg's referenced by the saved_vg struct were all being
freed properly, but the svg wrapper struct itself was not
being freed.
---
 lib/cache/lvmcache.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c306a3a..1b405e7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -295,6 +295,11 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 		_saved_vg_free(svg, 0, 1);
 	else
 		_saved_vg_free(svg, 1, 1);
+
+	if (!svg->saved_vg_old && !svg->saved_vg_new) {
+		dm_hash_remove(_saved_vg_hash, svg->vgid);
+		dm_free(svg);
+	}
 }
 
 void lvmcache_save_vg(struct volume_group *vg, int precommitted)
@@ -2515,6 +2520,7 @@ static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 static void _destroy_saved_vg(struct saved_vg *svg)
 {
 	_saved_vg_free(svg, 1, 1);
+	dm_free(svg);
 }
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)


