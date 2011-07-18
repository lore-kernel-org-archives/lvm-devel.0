From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Jul 2011 14:48:30 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c testclient.c
Message-ID: <20110718144830.28439.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-18 14:48:30

Modified files:
	daemons/lvmetad: lvmetad-core.c testclient.c 

Log message:
	Start filling in the core LVMetaD functionality and the corresponding
	testclient bits.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/06/27 14:03:59	1.5
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/18 14:48:30	1.6
@@ -1,26 +1,114 @@
+#include <assert.h>
+
+#include "libdevmapper.h"
+#include <malloc.h>
+#include <stdint.h>
+
 #include "metadata-exported.h"
 #include "../common/daemon-server.h"
 
 typedef struct {
+	struct dm_pool *mem;
+	struct dm_hash_table *pvids;
+	struct dm_hash_table *vgs;
 } lvmetad_state;
 
+static response vg_by_uuid(lvmetad_state *s, request r)
+{
+	const char *uuid = daemon_request_str(r, "uuid", "NONE");
+	fprintf(stderr, "[D] vg_by_uuid: %s (vgs = %p)\n", uuid, s->vgs);
+	struct config_node *metadata = dm_hash_lookup(s->vgs, uuid);
+	if (!metadata)
+		return daemon_reply_simple("failed", "reason = %s", "uuid not found", NULL);
+	fprintf(stderr, "[D] metadata: %p\n", metadata);
+
+	response res = { .buffer = NULL };
+	struct config_node *n;
+	res.cft = create_config_tree(NULL, 0);
+
+	/* The response field */
+	res.cft->root = n = create_config_node(res.cft, "response");
+	n->v->type = CFG_STRING;
+	n->v->v.str = "OK";
+
+	/* The metadata section */
+	n = n->sib = create_config_node(res.cft, "metadata");
+	n->v = NULL;
+	n->parent = res.cft->root;
+	n->child = clone_config_node(res.cft, metadata, 1);
+	res.error = 0;
+	fprintf(stderr, "[D] vg_by_uuid signing off\n");
+	return res;
+}
+
+static response pv_add(lvmetad_state *s, request r)
+{
+	const struct config_node *metadata = find_config_node(r.cft->root, "metadata");
+	const char *pvid = daemon_request_str(r, "uuid", NULL);
+	fprintf(stderr, "[D] pv_add buffer: %s\n", r.buffer);
+
+	if (!pvid)
+		return daemon_reply_simple("failed", "reason = %s", "need PV UUID", NULL);
+
+	if (metadata) {
+		const char *vgid = daemon_request_str(r, "metadata/id", NULL);
+		if (!vgid)
+			return daemon_reply_simple("failed", "reason = %s", "need VG UUID", NULL);
+		// TODO
+		const struct config_node *metadata_clone =
+			clone_config_node_with_mem(s->mem, metadata, 0);
+		dm_hash_insert(s->vgs, vgid, (void*) metadata_clone);
+		fprintf(stderr, "[D] metadata stored at %p\n", metadata_clone);
+	}
+
+	return daemon_reply_simple("OK", NULL);
+}
+
+static void pv_del(lvmetad_state *s, request r)
+{
+}
+
 static response handler(daemon_state s, client_handle h, request r)
 {
-	fprintf(stderr, "[D] REQUEST: %s, param = %d\n", daemon_request_str(r, "request", "NONE"),
-		                                         daemon_request_int(r, "param", -1));
-	return daemon_reply_simple("hey there", "param = %d", 42, NULL);
+	lvmetad_state *state = s.private;
+	const char *rq = daemon_request_str(r, "request", "NONE");
+
+	fprintf(stderr, "[D] REQUEST: %s\n", rq);
+
+	if (!strcmp(rq, "pv_add"))
+		return pv_add(state, r);
+	else if (!strcmp(rq, "pv_del"))
+		pv_del(state, r);
+	else if (!strcmp(rq, "vg_by_uuid"))
+		return vg_by_uuid(state, r);
+
+	return daemon_reply_simple("OK", NULL);
 }
 
-static int setup_post(daemon_state *s)
+static int init(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
 
+	ls->pvids = dm_hash_create(32);
+	ls->vgs = dm_hash_create(32);
+	ls->mem = dm_pool_create("lvmetad", 1024); /* whatever */
+	fprintf(stderr, "[D] initialised state: vgs = %p\n", ls->vgs);
+	if (!ls->pvids || !ls->vgs || !ls->mem)
+		return 0;
+
 	/* if (ls->initial_registrations)
 	   _process_initial_registrations(ds->initial_registrations); */
 
 	return 1;
 }
 
+static int fini(daemon_state *s)
+{
+	lvmetad_state *ls = s->private;
+	dm_pool_destroy(ls->mem);
+	return 1;
+}
+
 static void usage(char *prog, FILE *file)
 {
 	fprintf(file, "Usage:\n"
@@ -39,8 +127,10 @@
 	lvmetad_state ls;
 	int _restart = 0;
 
+	s.name = "lvmetad";
 	s.private = &ls;
-	s.setup_post = setup_post;
+	s.daemon_init = init;
+	s.daemon_fini = fini;
 	s.handler = handler;
 	s.socket_path = "/var/run/lvm/lvmetad.socket";
 	s.pidfile = "/var/run/lvm/lvmetad.pid";
--- LVM2/daemons/lvmetad/testclient.c	2011/06/27 14:03:59	1.6
+++ LVM2/daemons/lvmetad/testclient.c	2011/07/18 14:48:30	1.7
@@ -1,14 +1,47 @@
 #include "lvmetad-client.h"
 
+const char *uuid1 = "abcd-efgh";
+const char *uuid2 = "bbcd-efgh";
+const char *vgid = "yada-yada";
+
+const char *metadata2 = "{\n"
+	"id = \"yada-yada\"\n"
+	"seqno = 15\n"
+	"status = [\"READ\", \"WRITE\"]\n"
+	"flags = []\n"
+	"extent_size = 8192\n"
+	"physical_volumes {\n"
+	"    pv0 {\n"
+	"        id = \"abcd-efgh\"\n"
+	"    }\n"
+	"    pv1 {\n"
+	"        id = \"bbcd-efgh\"\n"
+	"    }\n"
+	"}\n"
+	"}\n";
+
+void pv_add(daemon_handle h, const char *uuid, const char *metadata)
+{
+	daemon_reply reply = daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
+						             "metadata = %b", metadata,
+						             NULL);
+	const char *repl = daemon_reply_str(reply, "response", NULL);
+	fprintf(stderr, "[C] REPLY: %s\n", repl);
+	if (!strcmp(repl, "failed"))
+		fprintf(stderr, "[C] REASON: %s\n", daemon_reply_str(reply, "reason", "unknown"));
+	daemon_reply_destroy(reply);
+}
+
 int main() {
 	daemon_handle h = lvmetad_open();
-	int i;
-	for (i = 0; i < 5; ++i ) {
-		daemon_reply reply = daemon_send_simple(h, "hello world", "param = %d", 3, NULL);
-		fprintf(stderr, "[C] REPLY: %s, param = %d\n", daemon_reply_str(reply, "request", "NONE"),
-			                                       daemon_reply_int(reply, "param", -1));
-		daemon_reply_destroy(reply);
-	}
+
+	pv_add(h, uuid1, NULL);
+	pv_add(h, uuid2, metadata2);
+
+	daemon_reply reply = daemon_send_simple(h, "vg_by_uuid", "uuid = %s", vgid, NULL);
+	fprintf(stderr, "[C] reply buffer: %s\n", reply.buffer);
+	daemon_reply_destroy(reply);
+
 	daemon_close(h);
 	return 0;
 }


