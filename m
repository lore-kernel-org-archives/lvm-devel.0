From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:31 +0000 (UTC)
Subject: master - cleanup: use simplier structure initialization
Message-ID: <20130615221631.E43EC60D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e19410d935134794b7a206b5300e43be44c8a28
Commit:        5e19410d935134794b7a206b5300e43be44c8a28
Parent:        636c51ae3f0fda00b38851ead7f419bc834786a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 22:00:44 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:33 2013 +0200

cleanup: use simplier structure initialization

And also use static struct for _out_spec.
---
 daemons/dmeventd/dmeventd.c |    4 ++--
 lib/config/config.c         |   20 +++++++++++---------
 libdm/libdm-config.c        |   14 +++++++++-----
 3 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 64e1683..50bd1df 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1830,8 +1830,8 @@ static void _daemonize(void)
 
 static void restart(void)
 {
-	struct dm_event_fifos fifos;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_fifos fifos = { 0 };
+	struct dm_event_daemon_message msg = { 0 };
 	int i, count = 0;
 	char *message;
 	int length;
diff --git a/lib/config/config.c b/lib/config/config.c
index cda9b83..7b6ac7b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -879,16 +879,18 @@ int config_write(struct dm_config_tree *cft,
 		 int withcomment, int withversion,
 		 const char *file, int argc, char **argv)
 {
-	struct out_baton baton = {0, 0, 0};
+	static const struct dm_config_node_out_spec _out_spec = {
+		.prefix_fn = _out_prefix_fn,
+		.line_fn = _out_line_fn,
+		.suffix_fn = _out_suffix_fn
+	};
 	const struct dm_config_node *cn;
-	const struct dm_config_node_out_spec out_spec = {.prefix_fn = _out_prefix_fn,
-							 .line_fn = _out_line_fn,
-							 .suffix_fn = _out_suffix_fn};
+	struct out_baton baton = {
+		.withcomment = withcomment,
+		.withversion = withversion
+	};
 	int r = 1;
 
-	baton.withcomment = withcomment;
-	baton.withversion = withversion;
-
 	if (!file) {
 		baton.fp = stdout;
 		file = "stdout";
@@ -899,13 +901,13 @@ int config_write(struct dm_config_tree *cft,
 
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
-		if (!dm_config_write_node_out(cft->root, &out_spec, &baton)) {
+		if (!dm_config_write_node_out(cft->root, &_out_spec, &baton)) {
 			log_error("Failure while writing to %s", file);
 			r = 0;
 		}
 	} else while (argc--) {
 		if ((cn = dm_config_find_node(cft->root, *argv))) {
-			if (!dm_config_write_one_node_out(cn, &out_spec, &baton)) {
+			if (!dm_config_write_one_node_out(cn, &_out_spec, &baton)) {
 				log_error("Failure while writing to %s", file);
 				r = 0;
 			}
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index dfd9174..3385e18 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -346,12 +346,16 @@ static int _write_node(const struct dm_config_node *cn, int only_one,
 		       const struct dm_config_node_out_spec *out_spec,
 		       void *baton)
 {
-	struct config_output out;
-	if (!(out.mem = dm_pool_create("config_output", 1024)))
+	struct config_output out = {
+		.mem = dm_pool_create("config_output", 1024),
+		.putline = putline,
+		.spec = out_spec,
+		.baton = baton
+	};
+
+	if (!out.mem)
 		return_0;
-	out.putline = putline;
-	out.spec = out_spec;
-	out.baton = baton;
+
 	if (!_write_config(cn, only_one, &out, 0)) {
 		dm_pool_destroy(out.mem);
 		return_0;


