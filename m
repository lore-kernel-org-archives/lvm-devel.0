From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 20:03:55 +0000 (UTC)
Subject: master - lvmetad: Implement a "dump" request to capture lvmetad state.
Message-ID: <20121011200355.EB7EF22BD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a63b46bf36b22b83ff05f2d3529bc22a38ff56d3
Commit:        a63b46bf36b22b83ff05f2d3529bc22a38ff56d3
Parent:        b165e9f3f8fe757e2dc330f6952856908fb131d8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 20:31:29 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 20:31:29 2012 +0200

lvmetad: Implement a "dump" request to capture lvmetad state.

---
 daemons/lvmetad/lvmetad-core.c |   81 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 80 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 47b07aa..99ae99f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -942,6 +942,82 @@ static response vg_remove(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+static void _dump_cft(struct buffer *buf, struct dm_hash_table *ht, const char *key_addr)
+{
+	struct dm_hash_node *n = dm_hash_get_first(ht);
+	while (n) {
+		struct dm_config_tree *cft = dm_hash_get_data(ht, n);
+		const char *key_backup = cft->root->key;
+		cft->root->key = dm_config_find_str(cft->root, key_addr, "unknown");
+		dm_config_write_node(cft->root, buffer_line, buf);
+		cft->root->key = key_backup;
+		n = dm_hash_get_next(ht, n);
+	}
+}
+
+static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
+{
+	char *append;
+	struct dm_hash_node *n = dm_hash_get_first(ht);
+
+	buffer_append(buf, name);
+	buffer_append(buf, " {\n");
+
+	while (n) {
+		const char *key = dm_hash_get_key(ht, n),
+			   *val = dm_hash_get_data(ht, n);
+		buffer_append(buf, "    ");
+		if (int_key)
+			dm_asprintf(&append, "%d = \"%s\"", *(int*)key, val);
+		else
+			dm_asprintf(&append, "%s = \"%s\"", key, val);
+		if (append)
+			buffer_append(buf, append);
+		buffer_append(buf, "\n");
+		dm_free(append);
+		n = dm_hash_get_next(ht, n);
+	}
+	buffer_append(buf, "}\n");
+}
+
+static response dump(lvmetad_state *s)
+{
+	response res;
+	struct buffer *b = &res.buffer;
+
+	buffer_init(b);
+
+	/* Lock everything so that we get a consistent dump. */
+
+	lock_vgid_to_metadata(s);
+	lock_pvid_to_pvmeta(s);
+	lock_pvid_to_vgid(s);
+
+	buffer_append(b, "# VG METADATA\n\n");
+	_dump_cft(b, s->vgid_to_metadata, "metadata/id");
+
+	buffer_append(b, "\n# PV METADATA\n\n");
+	_dump_cft(b, s->pvid_to_pvmeta, "pvmeta/id");
+
+	buffer_append(b, "\n# VGID to VGNAME mapping\n\n");
+	_dump_pairs(b, s->vgid_to_vgname, "vgid_to_vgname", 0);
+
+	buffer_append(b, "\n# VGNAME to VGID mapping\n\n");
+	_dump_pairs(b, s->vgname_to_vgid, "vgname_to_vgid", 0);
+
+	buffer_append(b, "\n# PVID to VGID mapping\n\n");
+	_dump_pairs(b, s->pvid_to_vgid, "pvid_to_vgid", 0);
+
+	buffer_append(b, "\n# DEVICE to PVID mapping\n\n");
+	_dump_pairs(b, s->device_to_pvid, "device_to_pvid", 1);
+
+	unlock_pvid_to_vgid(s);
+	unlock_pvid_to_pvmeta(s);
+	unlock_vgid_to_metadata(s);
+
+	return res;
+}
+
 static response handler(daemon_state s, client_handle h, request r)
 {
 	lvmetad_state *state = s.private;
@@ -956,7 +1032,7 @@ static response handler(daemon_state s, client_handle h, request r)
 		return daemon_reply_simple("OK", NULL);
 	}
 
-	if (strcmp(token, state->token)) {
+	if (strcmp(token, state->token) && strcmp(rq, "dump")) {
 		pthread_mutex_unlock(&state->token_lock);
 		return daemon_reply_simple("token_mismatch",
 					   "expected = %s", state->token,
@@ -997,6 +1073,9 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "vg_list"))
 		return vg_list(state, r);
 
+	if (!strcmp(rq, "dump"))
+		return dump(state);
+
 	return reply_fail("request not implemented");
 }
 


