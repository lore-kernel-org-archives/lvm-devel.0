From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 15:10:18 +0000 (UTC)
Subject: master - lvmetad: Make it possible to clear the outdated PVs list for a VG.
Message-ID: <20150612151018.6A80660AAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f91ad64c3c76ab31efe6bfad362adefd47adff2
Commit:        4f91ad64c3c76ab31efe6bfad362adefd47adff2
Parent:        756d027da5cd0e10b10181515a75ecf8d275a5b3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 10 16:18:57 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 10 16:18:57 2015 +0200

lvmetad: Make it possible to clear the outdated PVs list for a VG.

---
 daemons/lvmetad/lvmetad-core.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index db8d918..57a86e4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1131,6 +1131,21 @@ out_of_mem:
 				   NULL);
 }
 
+static response vg_clear_outdated_pvs(lvmetad_state *s, request r)
+{
+	struct dm_config_tree *outdated_pvs;
+	const char *vgid = daemon_request_str(r, "vgid", NULL);
+
+	if (!vgid)
+		return reply_fail("need VG UUID");
+
+	if ((outdated_pvs = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid))) {
+		dm_config_destroy(outdated_pvs);
+		dm_hash_remove(s->vgid_to_outdated_pvs, vgid);
+	}
+	return daemon_reply_simple("OK", NULL);
+}
+
 static response vg_update(lvmetad_state *s, request r)
 {
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
@@ -1289,6 +1304,9 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "vg_update"))
 		return vg_update(state, r);
 
+	if (!strcmp(rq, "vg_clear_outdated_pvs"))
+		return vg_clear_outdated_pvs(state, r);
+
 	if (!strcmp(rq, "vg_remove"))
 		return vg_remove(state, r);
 


