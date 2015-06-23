From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Jun 2015 21:39:12 +0000 (UTC)
Subject: master - lvmetad: add invalidation method
Message-ID: <20150623213912.4752060CD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf77f717119c0e567a36d7d48e06d81bf5aa2fb9
Commit:        bf77f717119c0e567a36d7d48e06d81bf5aa2fb9
Parent:        4c6b3f5ec37bf4e0d361d241a0b6f9d0902a4359
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 21 09:40:13 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 16:36:33 2015 -0500

lvmetad: add invalidation method

Add the ability to invalidate global or individual VG metadata.
The invalid state is returned to lvm commands along with the metadata.
This allows lvm commands to detect stale metadata from the cache and
reread the latest metadata from disk (in a subsequent patch.)

These changes do not change the protocol or compatibility between
lvm commands and lvmetad.

Global information
------------------

Global information refers to metadata that is not isolated
to a single VG , e.g. the list of vg names, or the list of pvs.

When an external system, e.g. a locking system, detects that global
information has been changed from another host (e.g. a new vg has been
created) it sends lvmetad the message: set_global_info: global_invalid=1.
lvmetad sets the global invalid flag to indicate that its cached data is
stale.

When lvm commands request information from lvmetad, lvmetad returns the
cached information, along with an additional top-level config node called
"global_invalid".  This new info tells the lvm command that the cached
information is stale.

When an lvm command sees global_invalid from lvmated, it knows it should
rescan devices and update lvmetad with the latest information.  When this
is complete, it sends lvmetad the message: set_global_info:
global_invalid=0, and lvmetad clears the global invalid flag.  Further lvm
commands will use the lvmetad cache until it is invalidated again.

The most common commands that cause global invalidation are vgcreate and
vgextend.  These are uncommon compared to commands that report global
information, e.g. vgs.  So, the percentage of lvmetad replies containing
global_invalid should be very small.

VG information
--------------

VG information refers to metadata that is isolated to a single VG,
e.g. an LV or the size of an LV.

When an external system determines that VG information has been changed
from another host (e.g. an lvcreate or lvresize), it sends lvmetad the
message: set_vg_info: uuid=X version=N.  X is the VG uuid, and N is the
latest VG seqno that was written.  lvmetad checks the seqno of its cached
VG, and if the version from the message is newer, it sets an invalid flag
for the cached VG.  The invalid flag, along with the newer seqno are saved
in a new vg_info struct.

When lvm commands request VG metadata from lvmetad, lvmetad includes the
invalid flag along with the VG metadata.  The lvm command checks for this
flag, and rereads the VG from disk if set.  The VG read from disk is sent
to lvmetad.  lvmetad sees that the seqno in the new version matches the
seqno from the last set_vg_info message, and clears the vg invalid flag.
Further lvm commands will use the VG metadata from lvmetad until it is
next invalidated.
---
 daemons/lvmetad/lvmetad-core.c |  289 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 288 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index dc0c92a..7f2405c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -28,6 +28,100 @@
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
+/*
+ * valid/invalid state of cached metadata
+ *
+ * Normally when using lvmetad, the state is kept up-to-date through a
+ * combination of notifications from clients and updates triggered by uevents.
+ * When using lvmlockd, the lvmetad state is expected to become out of
+ * date (invalid/stale) when other hosts make changes to the metadata on disk.
+ *
+ * To deal with this, the metadata cached in lvmetad can be flagged as invalid.
+ * This invalid flag is returned along with the metadata when read by a
+ * command.  The command can check for the invalid flag and decide that it
+ * should either use the stale metadata (uncommon), or read the latest metadata
+ * from disk rather than using the invalid metadata that was returned.  If the
+ * command reads the latest metadata from disk, it can choose to send it to
+ * lvmetad to update the cached copy and clear the invalid flag in lvmetad.
+ * Otherwise, the next command to read the metadata from lvmetad will also
+ * receive the invalid metadata with the invalid flag (and like the previous
+ * command, it too may choose to read the latest metadata from disk and can
+ * then also choose to update the lvmetad copy.)
+ *
+ * For purposes of tracking the invalid state, LVM metadata is considered
+ * to be either VG-specific or global.  VG-specific metadata is metadata
+ * that is isolated to a VG, such as the LVs it contains.  Global
+ * metadata is metadata that is not isolated to a single VG.  Global
+ * metdata includes:
+ * . the VG namespace (which VG names are used)
+ * . the set of orphan PVs (which PVs are in VGs and which are not)
+ * . properties of orphan PVs (the size of an orphan PV)
+ *
+ * If the metadata for a single VG becomes invalid, the VGFL_INVALID
+ * flag can be set in the vg_info struct for that VG.  If the global
+ * metdata becomes invalid, the GLFL_INVALID flag can be set in the
+ * lvmetad daemon state.
+ *
+ * If a command reads VG metadata and VGFL_INVALID is set, an
+ * extra config node called "vg_invalid" is added to the config
+ * data returned to the command.
+ *
+ * If a command reads global metdata and GLFL_INVALID is set, an
+ * extra config node called "global_invalid" is added to the
+ * config data returned to the command.
+ *
+ * If a command sees vg_invalid, and wants the latest VG metadata,
+ * it only needs to scan disks of the PVs in that VG.
+ * It can then use vg_update to send the latest metadata to lvmetad
+ * which clears the VGFL_INVALID flag.
+ *
+ * If a command sees global_invalid, and wants the latest metadata,
+ * it should scan all devices to update lvmetad, and then send
+ * lvmetad the "set_global_info global_invalid=0" message to clear
+ * GLFL_INVALID.
+ *
+ * (When rescanning devices to update lvmetad, the command must use
+ * the global filter cmd->lvmetad_filter so that it processes the same
+ * devices that are seen by lvmetad.)
+ *
+ * The lvmetad INVALID flags can be set by sending lvmetad the messages:
+ *
+ * . set_vg_info with the latest VG seqno.  If the VG seqno is larger
+ *   than the cached VG seqno, VGFL_INVALID is set for the VG.
+ *
+ * . set_global_info with global_invalid=1 sets GLFL_INVALID.
+ *
+ * Different entities could use these functions to invalidate metadata
+ * if/when they detected that the cache is stale.  How they detect that
+ * the cache is stale depends on the details of the specific entity.
+ *
+ * In the case of lvmlockd, it embeds values into its locks to keep track
+ * of when other nodes have changed metadata on disk related to those locks.
+ * When acquring locks it can look at these values and detect that
+ * the metadata associated with the lock has been changed.
+ * When the values change, it uses set_vg_info/set_global_info to
+ * invalidate the lvmetad cache.
+ *
+ * The values that lvmlockd distributes through its locks are the
+ * latest VG seqno in VG locks and a global counter in the global lock.
+ * When a host acquires a VG lock and sees that the embedded seqno is
+ * larger than it was previously, it knows that it should invalidate the
+ * lvmetad cache for the VG.  If the host acquires the global lock
+ * and sees that the counter is larger than previously, it knows that
+ * it should invalidate the global info in lvmetad.  This invalidation
+ * is done before the lock is returned to the command.  This way the
+ * invalid flag will be set on the metadata before the command reads
+ * it from lvmetad.
+ */
+
+struct vg_info {
+	int64_t external_version;
+	uint32_t flags; /* VGFL_ */
+};
+
+#define GLFL_INVALID 0x00000001
+#define VGFL_INVALID 0x00000001
+
 typedef struct {
 	log_state *log; /* convenience */
 	const char *log_config;
@@ -38,6 +132,7 @@ typedef struct {
 	struct dm_hash_table *vgid_to_metadata;
 	struct dm_hash_table *vgid_to_vgname;
 	struct dm_hash_table *vgid_to_outdated_pvs;
+	struct dm_hash_table *vgid_to_info;
 	struct dm_hash_table *vgname_to_vgid;
 	struct dm_hash_table *pvid_to_vgid;
 	struct {
@@ -48,6 +143,7 @@ typedef struct {
 		pthread_mutex_t pvid_to_vgid;
 	} lock;
 	char token[128];
+	uint32_t flags; /* GLFL_ */
 	pthread_mutex_t token_lock;
 } lvmetad_state;
 
@@ -68,6 +164,7 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_destroy(s->vgid_to_metadata);
 	dm_hash_destroy(s->vgid_to_vgname);
 	dm_hash_destroy(s->vgid_to_outdated_pvs);
+	dm_hash_destroy(s->vgid_to_info);
 	dm_hash_destroy(s->vgname_to_vgid);
 
 	dm_hash_destroy(s->device_to_pvid);
@@ -81,6 +178,7 @@ static void create_metadata_hashes(lvmetad_state *s)
 	s->vgid_to_metadata = dm_hash_create(32);
 	s->vgid_to_vgname = dm_hash_create(32);
 	s->vgid_to_outdated_pvs = dm_hash_create(32);
+	s->vgid_to_info = dm_hash_create(32);
 	s->pvid_to_vgid = dm_hash_create(32);
 	s->vgname_to_vgid = dm_hash_create(32);
 }
@@ -244,6 +342,30 @@ static int update_pv_status(lvmetad_state *s,
 	return complete;
 }
 
+static struct dm_config_node *add_last_node(struct dm_config_tree *cft, const char *node_name)
+{
+	struct dm_config_node *cn, *last;
+
+	cn = cft->root;
+	last = cn;
+
+	while (cn->sib) {
+		last = cn->sib;
+		cn = last;
+	}
+
+	cn = dm_config_create_node(cft, node_name);
+	if (!cn)
+		return NULL;
+
+	cn->v = NULL;
+	cn->sib = NULL;
+	cn->parent = cft->root;
+	last->sib = cn;
+
+	return cn;
+}
+
 static struct dm_config_node *make_pv_node(lvmetad_state *s, const char *pvid,
 					   struct dm_config_tree *cft,
 					   struct dm_config_node *parent,
@@ -307,6 +429,9 @@ static response pv_list(lvmetad_state *s, request r)
 		cn = make_pv_node(s, id, res.cft, cn_pvs, cn);
 	}
 
+	if (s->flags & GLFL_INVALID)
+		add_last_node(res.cft, "global_invalid");
+
 	unlock_pvid_to_pvmeta(s);
 
 	return res;
@@ -351,6 +476,9 @@ static response pv_lookup(lvmetad_state *s, request r)
 	pv->key = "physical_volume";
 	unlock_pvid_to_pvmeta(s);
 
+	if (s->flags & GLFL_INVALID)
+		add_last_node(res.cft, "global_invalid");
+
 	return res;
 }
 
@@ -419,6 +547,9 @@ static response vg_list(lvmetad_state *s, request r)
 	}
 
 	unlock_vgid_to_metadata(s);
+
+	if (s->flags & GLFL_INVALID)
+		add_last_node(res.cft, "global_invalid");
 bad:
 	return res;
 }
@@ -496,6 +627,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *cft;
 	struct dm_config_node *metadata, *n;
+	struct vg_info *info;
 	response res = { 0 };
 
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
@@ -560,6 +692,16 @@ static response vg_lookup(lvmetad_state *s, request r)
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
 	chain_outdated_pvs(s, uuid, res.cft, n);
 
+        if (s->flags & GLFL_INVALID)
+                add_last_node(res.cft, "global_invalid");
+
+	info = dm_hash_lookup(s->vgid_to_info, uuid);
+	if (info && (info->flags & VGFL_INVALID)) {
+		n = add_last_node(res.cft, "vg_invalid");
+		if (!n)
+			goto bad;
+	}
+
 	return res;
 bad:
 	unlock_vg(s, uuid);
@@ -1089,6 +1231,24 @@ static response vg_clear_outdated_pvs(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+static void vg_info_update(lvmetad_state *s, const char *uuid,
+                           struct dm_config_node *metadata)
+{
+	struct vg_info *info;
+	int64_t cache_version;
+
+	cache_version = dm_config_find_int64(metadata, "metadata/seqno", -1);
+	if (cache_version == -1)
+		return;
+
+	info = (struct vg_info *) dm_hash_lookup(s->vgid_to_info, uuid);
+	if (!info)
+		return;
+
+	if (cache_version >= info->external_version)
+		info->flags &= ~VGFL_INVALID;
+}
+
 static response vg_update(lvmetad_state *s, request r)
 {
 	struct dm_config_node *metadata = dm_config_find_node(r.cft->root, "metadata");
@@ -1106,6 +1266,8 @@ static response vg_update(lvmetad_state *s, request r)
 		 * call; if client does not commit, die */
 		if (!update_metadata(s, vgname, vgid, metadata, NULL, NULL))
 			return reply_fail("metadata update failed");
+
+		vg_info_update(s, vgid, metadata);
 	}
 	return daemon_reply_simple("OK", NULL);
 }
@@ -1126,6 +1288,70 @@ static response vg_remove(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+static response set_global_info(lvmetad_state *s, request r)
+{
+	const int global_invalid = daemon_request_int(r, "global_invalid", -1);
+
+	if (global_invalid == 1)
+		s->flags |= GLFL_INVALID;
+
+	else if (global_invalid == 0)
+		s->flags &= ~GLFL_INVALID;
+
+	return daemon_reply_simple("OK", NULL);
+}
+
+static response get_global_info(lvmetad_state *s, request r)
+{
+	return daemon_reply_simple("OK", "global_invalid = %d",
+					 (s->flags & GLFL_INVALID) ? 1 : 0,
+					 NULL);
+}
+
+static response set_vg_info(lvmetad_state *s, request r)
+{
+	struct dm_config_tree *vg;
+	struct vg_info *info;
+	const char *uuid = daemon_request_str(r, "uuid", NULL);
+	const int64_t new_version = daemon_request_int(r, "version", -1);
+	int64_t cache_version;
+
+	if (!uuid)
+		goto out;
+
+	if (new_version == -1)
+		goto out;
+
+	vg = dm_hash_lookup(s->vgid_to_metadata, uuid);
+	if (!vg)
+		goto out;
+
+	if (!new_version)
+		goto inval;
+
+	cache_version = dm_config_find_int64(vg->root, "metadata/seqno", -1);
+
+	if (cache_version != -1 && new_version != -1 && cache_version >= new_version)
+		goto out;
+inval:
+	info = dm_hash_lookup(s->vgid_to_info, uuid);
+	if (!info) {
+		info = malloc(sizeof(struct vg_info));
+		if (!info)
+			goto bad;
+		memset(info, 0, sizeof(struct vg_info));
+		dm_hash_insert(s->vgid_to_info, uuid, (void*)info);
+	}
+
+	info->external_version = new_version;
+	info->flags |= VGFL_INVALID;
+
+out:
+	return daemon_reply_simple("OK", NULL);
+bad:
+	return reply_fail("out of memory");
+}
+
 static void _dump_cft(struct buffer *buf, struct dm_hash_table *ht, const char *key_addr)
 {
 	struct dm_hash_node *n;
@@ -1163,6 +1389,52 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 	buffer_append(buf, "}\n");
 }
 
+static void _dump_info_version(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
+{
+	char *append;
+	struct dm_hash_node *n = dm_hash_get_first(ht);
+	struct vg_info *info;
+
+	buffer_append(buf, name);
+	buffer_append(buf, " {\n");
+
+	while (n) {
+		const char *key = dm_hash_get_key(ht, n);
+		info = dm_hash_get_data(ht, n);
+		buffer_append(buf, "    ");
+		(void) dm_asprintf(&append, "%s = %lld", key, (long long)info->external_version);
+		if (append)
+			buffer_append(buf, append);
+		buffer_append(buf, "\n");
+		dm_free(append);
+		n = dm_hash_get_next(ht, n);
+	}
+	buffer_append(buf, "}\n");
+}
+
+static void _dump_info_flags(struct buffer *buf, struct dm_hash_table *ht, const char *name, int int_key)
+{
+	char *append;
+	struct dm_hash_node *n = dm_hash_get_first(ht);
+	struct vg_info *info;
+
+	buffer_append(buf, name);
+	buffer_append(buf, " {\n");
+
+	while (n) {
+		const char *key = dm_hash_get_key(ht, n);
+		info = dm_hash_get_data(ht, n);
+		buffer_append(buf, "    ");
+		(void) dm_asprintf(&append, "%s = %llx", key, (long long)info->flags);
+		if (append)
+			buffer_append(buf, append);
+		buffer_append(buf, "\n");
+		dm_free(append);
+		n = dm_hash_get_next(ht, n);
+	}
+	buffer_append(buf, "}\n");
+}
+
 static response dump(lvmetad_state *s)
 {
 	response res = { 0 };
@@ -1197,6 +1469,12 @@ static response dump(lvmetad_state *s)
 	buffer_append(b, "\n# DEVICE to PVID mapping\n\n");
 	_dump_pairs(b, s->device_to_pvid, "device_to_pvid", 1);
 
+	buffer_append(b, "\n# VGID to INFO version mapping\n\n");
+	_dump_info_version(b, s->vgid_to_info, "vgid_to_info", 0);
+
+	buffer_append(b, "\n# VGID to INFO flags mapping\n\n");
+	_dump_info_flags(b, s->vgid_to_info, "vgid_to_info", 0);
+
 	unlock_pvid_to_vgid(s);
 	unlock_pvid_to_pvmeta(s);
 	unlock_vgid_to_metadata(s);
@@ -1218,7 +1496,7 @@ static response handler(daemon_state s, client_handle h, request r)
 		return daemon_reply_simple("OK", NULL);
 	}
 
-	if (strcmp(token, state->token) && strcmp(rq, "dump")) {
+	if (strcmp(token, state->token) && strcmp(rq, "dump") && strcmp(token, "skip")) {
 		pthread_mutex_unlock(&state->token_lock);
 		return daemon_reply_simple("token_mismatch",
 					   "expected = %s", state->token,
@@ -1262,6 +1540,15 @@ static response handler(daemon_state s, client_handle h, request r)
 	if (!strcmp(rq, "vg_list"))
 		return vg_list(state, r);
 
+	if (!strcmp(rq, "set_global_info"))
+		return set_global_info(state, r);
+
+	if (!strcmp(rq, "get_global_info"))
+		return get_global_info(state, r);
+
+	if (!strcmp(rq, "set_vg_info"))
+		return set_vg_info(state, r);
+
 	if (!strcmp(rq, "dump"))
 		return dump(state);
 


