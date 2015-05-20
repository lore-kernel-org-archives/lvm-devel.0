From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:05 +0000 (UTC)
Subject: master - lvmetad: Attach an outdated_pvs list to vg_lookup replies.
Message-ID: <20150520174805.89CE660188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1562cd732060f995663a586566b15bc129e62b64
Commit:        1562cd732060f995663a586566b15bc129e62b64
Parent:        da1527d65dbe474fe4c9e620ad028a9a09213ac8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 16:39:32 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:13 2015 +0200

lvmetad: Attach an outdated_pvs list to vg_lookup replies.

---
 daemons/lvmetad/lvmetad-core.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index d14bac2..40cf7d4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -470,8 +470,13 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 	list->v = v;
 }
 
-static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata)
+static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata, struct dm_config_node *last)
 {
+	struct dm_config_tree *cft = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid);
+	if (!cft)
+		return; /* nothing to chain in */
+	last->sib = dm_config_clone_node(metadata, dm_config_find_node(cft->root, "outdated_pvs/pv_list"), 0);
+	last->sib->key = "outdated_pvs";
 }
 
 static response vg_lookup(lvmetad_state *s, request r)
@@ -540,7 +545,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	unlock_vg(s, uuid);
 
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
-	chain_outdated_pvs(s, uuid, res.cft);
+	chain_outdated_pvs(s, uuid, res.cft, n);
 
 	return res;
 bad:


