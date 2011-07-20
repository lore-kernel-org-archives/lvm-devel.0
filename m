From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Jul 2011 15:15:42 -0000
Subject: LVM2/daemons/lvmetad testclient.c
Message-ID: <20110720151542.24036.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-20 15:15:42

Modified files:
	daemons/lvmetad: testclient.c 

Log message:
	Add code to lvmetad's testclient that scans an actual physical device,
	effectively emulating a future "pvscan --lvmetad" command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/lvmetad/testclient.c	2011/07/19 16:48:13	1.8
+++ LVM2/daemons/lvmetad/testclient.c	2011/07/20 15:15:41	1.9
@@ -1,8 +1,12 @@
 #include "lvmetad-client.h"
+#include "label.h"
+#include "lvmcache.h"
+#include "metadata.h"
 
 const char *uuid1 = "abcd-efgh";
 const char *uuid2 = "bbcd-efgh";
 const char *vgid = "yada-yada";
+const char *uuid3 = "cbcd-efgh";
 
 const char *metadata2 = "{\n"
 	"id = \"yada-yada\"\n"
@@ -23,27 +27,100 @@
 	"}\n"
 	"}\n";
 
-void pv_add(daemon_handle h, const char *uuid, const char *metadata)
-{
-	daemon_reply reply = daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
-						             "metadata = %b", metadata,
-						             NULL);
+void _handle_reply(daemon_reply reply) {
 	const char *repl = daemon_reply_str(reply, "response", NULL);
+	const char *status = daemon_reply_str(reply, "status", NULL);
+	const char *vgid = daemon_reply_str(reply, "vgid", NULL);
+
 	fprintf(stderr, "[C] REPLY: %s\n", repl);
 	if (!strcmp(repl, "failed"))
 		fprintf(stderr, "[C] REASON: %s\n", daemon_reply_str(reply, "reason", "unknown"));
+	if (vgid)
+		fprintf(stderr, "[C] VGID: %s\n", vgid);
+	if (status)
+		fprintf(stderr, "[C] STATUS: %s\n", status);
 	daemon_reply_destroy(reply);
 }
 
-int main() {
-	daemon_handle h = lvmetad_open();
+void _pv_add(daemon_handle h, const char *uuid, const char *metadata)
+{
+	daemon_reply reply = daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
+						             "metadata = %b", metadata,
+						             NULL);
+	_handle_reply(reply);
+}
 
-	pv_add(h, uuid1, NULL);
-	pv_add(h, uuid2, metadata2);
+int scan(daemon_handle h, char *fn) {
+	struct device *dev = dev_cache_get(fn, NULL);
 
-	daemon_reply reply = daemon_send_simple(h, "vg_by_uuid", "uuid = %s", vgid, NULL);
+	struct label *label;
+	if (!label_read(dev, &label, 0)) {
+		fprintf(stderr, "[C] no label found on %s\n", fn);
+		return;
+	}
+
+	char uuid[64];
+	id_write_format(dev->pvid, uuid, 64);
+	fprintf(stderr, "[C] found PV: %s\n", uuid);
+	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
+	struct physical_volume pv = { 0, };
+
+	if (!(info->fmt->ops->pv_read(info->fmt, dev_name(dev), &pv, 0))) {
+		fprintf(stderr, "[C] Failed to read PV %s", dev_name(dev));
+		return;
+	}
+
+	struct format_instance_ctx fic;
+	struct format_instance *fid = info->fmt->ops->create_instance(info->fmt, &fic);
+	struct metadata_area *mda;
+	struct volume_group *vg = NULL;
+	dm_list_iterate_items(mda, &info->mdas) {
+		struct volume_group *this = mda->ops->vg_read(fid, "", mda);
+		if (this && !vg || this->seqno > vg->seqno)
+			vg = this;
+	}
+	if (vg) {
+		char *buf = NULL;
+		/* TODO. This is not entirely correct, since export_vg_to_buffer
+		 * adds trailing garbage to the buffer. We may need to use
+		 * export_vg_to_config_tree and format the buffer ourselves. It
+		 * does, however, work for now, since the garbage is well
+		 * formatted and has no conflicting keys with the rest of the
+		 * request.  */
+		export_vg_to_buffer(vg, &buf);
+		daemon_reply reply =
+			daemon_send_simple(h, "pv_add", "uuid = %s", uuid,
+					      "metadata = %b", strchr(buf, '{'),
+					      NULL);
+		_handle_reply(reply);
+	}
+}
+
+void _dump_vg(daemon_handle h, const char *uuid)
+{
+	daemon_reply reply = daemon_send_simple(h, "vg_by_uuid", "uuid = %s", uuid, NULL);
 	fprintf(stderr, "[C] reply buffer: %s\n", reply.buffer);
 	daemon_reply_destroy(reply);
+}
+
+int main(int argc, char **argv) {
+	daemon_handle h = lvmetad_open();
+
+	if (argc > 1) {
+		int i;
+		struct cmd_context *cmd = create_toolcontext(0, NULL, 0);
+		for (i = 1; i < argc; ++i) {
+			const char *uuid = NULL;
+			scan(h, argv[i]);
+		}
+		destroy_toolcontext(cmd);
+		return 0;
+	}
+
+	_pv_add(h, uuid1, NULL);
+	_pv_add(h, uuid2, metadata2);
+	_dump_vg(h, vgid);
+	_pv_add(h, uuid3, NULL);
 
 	daemon_close(h);
 	return 0;


