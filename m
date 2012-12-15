From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:31 +0000 (UTC)
Subject: master - lvmetad: keep returned struct fully initialized
Message-ID: <20121215162531.70E01AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=399fc1bb33119d281f57108dba4bd9cd479ed8a0
Commit:        399fc1bb33119d281f57108dba4bd9cd479ed8a0
Parent:        a4269aadf320f36d3d6fa3a3b66dda98855e7bc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:38:07 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

lvmetad: keep returned struct fully initialized

Always clear the response structure.
Simplify daemon_reply initialization.
---
 daemons/lvmetad/lvmetad-core.c   |   11 +++++------
 libdaemon/client/daemon-client.c |    6 +++---
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 6c00146..cbeaae1 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -292,7 +292,7 @@ static response pv_list(lvmetad_state *s, request r)
 	struct dm_config_node *cn = NULL, *cn_pvs;
 	struct dm_hash_node *n;
 	const char *id;
-	response res;
+	response res = { 0 };
 
 	buffer_init( &res.buffer );
 
@@ -320,7 +320,7 @@ static response pv_lookup(lvmetad_state *s, request r)
 {
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t devt = daemon_request_int(r, "device", 0);
-	response res;
+	response res = { 0 };
 	struct dm_config_node *pv;
 
 	buffer_init( &res.buffer );
@@ -364,7 +364,7 @@ static response vg_list(lvmetad_state *s, request r)
 	struct dm_hash_node *n;
 	const char *id;
 	const char *name;
-	response res;
+	response res = { 0 };
 
 	buffer_init( &res.buffer );
 
@@ -434,7 +434,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *cft;
 	struct dm_config_node *metadata, *n;
-	response res;
+	response res = { 0 };
 
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
 	const char *name = daemon_request_str(r, "name", NULL);
@@ -492,7 +492,6 @@ static response vg_lookup(lvmetad_state *s, request r)
 	if (!(n = n->sib = dm_config_clone_node(res.cft, metadata, 1)))
 		goto bad;
 	n->parent = res.cft->root;
-	res.error = 0;
 	unlock_vg(s, uuid);
 
 	update_pv_status(s, res.cft, n, 1); /* FIXME report errors */
@@ -987,7 +986,7 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 
 static response dump(lvmetad_state *s)
 {
-	response res;
+	response res = { 0 };
 	struct buffer *b = &res.buffer;
 
 	buffer_init(b);
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index a010cc0..53bfa86 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -27,7 +27,7 @@
 
 daemon_handle daemon_open(daemon_info i) {
 	daemon_handle h = { .protocol_version = 0, .error = 0 };
-	daemon_reply r = { .cft = NULL };
+	daemon_reply r = { 0 };
 	struct sockaddr_un sockaddr = { .sun_family = AF_UNIX };
 
 	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0)
@@ -72,7 +72,7 @@ error:
 daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
 	struct buffer buffer;
-	daemon_reply reply = { .cft = NULL, .error = 0 };
+	daemon_reply reply = { 0 };
 	assert(h.socket_fd >= 0);
 	buffer = rq.buffer;
 
@@ -104,7 +104,7 @@ void daemon_reply_destroy(daemon_reply r) {
 
 daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 {
-	static const daemon_reply err = { .error = ENOMEM, .buffer = { 0, 0, NULL }, .cft = NULL };
+	static const daemon_reply err = { .error = ENOMEM };
 	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
 


