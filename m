From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:37 +0000 (UTC)
Subject: master - libdaemon: Extend and refactor APIs.
Message-ID: <20120926175537.D0B1BA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea14d5159cd3a196c0754f4e37539dee1eb2d169
Commit:        ea14d5159cd3a196c0754f4e37539dee1eb2d169
Parent:        72d82e21d44c48a3823156afa900eb071b3eb144
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 11 10:33:53 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 14:49:09 2012 +0200

libdaemon: Extend and refactor APIs.

- move common dm_config_tree manipulation functions from lvmetad-core to
  daemon-shared
- add config-tree-based request manipulation APIs to daemon-client
- factor out _v (va_list) variants of most variadic functions in libdaemon
---
 daemons/lvmetad/lvmetad-core.c   |  123 --------------------
 lib/config/config.c              |    1 +
 libdaemon/client/daemon-client.c |   74 +++++++++++--
 libdaemon/client/daemon-client.h |    6 +
 libdaemon/client/daemon-shared.c |  232 +++++++++++++++++++++++++++++++++++++-
 libdaemon/client/daemon-shared.h |   38 ++++++-
 libdaemon/server/daemon-server.c |   45 +++-----
 7 files changed, 354 insertions(+), 165 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 146ee69..c96e285 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -107,129 +107,6 @@ static struct dm_config_node *pvs(struct dm_config_node *vg)
 	return pv;
 }
 
-/*
- * TODO: This set_flag function is pretty generic and might make sense in a
- * library here or there.
- */
-static int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
-		     const char *field, const char *flag, int want) {
-	struct dm_config_value *value = NULL, *pred = NULL;
-	struct dm_config_node *node = dm_config_find_node(parent->child, field);
-	struct dm_config_value *new;
-
-	if (node)
-		value = node->v;
-
-	while (value && value->type != DM_CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
-		pred = value;
-		value = value->next;
-	}
-
-	if (value && want)
-		return 1;
-
-	if (!value && !want)
-		return 1;
-
-	if (value && !want) {
-		if (pred) {
-			pred->next = value->next;
-		} else if (value == node->v && value->next) {
-			node->v = value->next;
-		} else {
-			node->v->type = DM_CFG_EMPTY_ARRAY;
-		}
-	}
-
-	if (!value && want) {
-		if (!node) {
-			if (!(node = dm_config_create_node(cft, field)))
-				return 0;
-			node->sib = parent->child;
-			if (!(node->v = dm_config_create_value(cft)))
-				return 0;
-			node->v->type = DM_CFG_EMPTY_ARRAY;
-			node->parent = parent;
-			parent->child = node;
-		}
-		if (!(new = dm_config_create_value(cft))) {
-			/* FIXME error reporting */
-			return 0;
-		}
-		new->type = DM_CFG_STRING;
-		new->v.str = flag;
-		new->next = node->v;
-		node->v = new;
-	}
-
-	return 1;
-}
-
-static struct dm_config_node *make_config_node(struct dm_config_tree *cft,
-					       const char *key,
-					       struct dm_config_node *parent,
-					       struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn;
-
-	if (!(cn = dm_config_create_node(cft, key)))
-		return NULL;
-
-	cn->parent = parent;
-	cn->sib = NULL;
-	cn->v = NULL;
-	cn->child = NULL;
-
-	if (parent && parent->child && !pre_sib) { /* find the last one */
-		pre_sib = parent->child;
-		while (pre_sib && pre_sib->sib)
-			pre_sib = pre_sib->sib;
-	}
-
-	if (parent && !parent->child)
-		parent->child = cn;
-	if (pre_sib)
-		pre_sib->sib = cn;
-
-	return cn;
-}
-
-static struct dm_config_node *make_text_node(struct dm_config_tree *cft,
-					     const char *key,
-					     const char *value,
-					     struct dm_config_node *parent,
-					     struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn;
-
-	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
-	    !(cn->v = dm_config_create_value(cft)))
-		return NULL;
-
-	cn->v->type = DM_CFG_STRING;
-	cn->v->v.str = value;
-	return cn;
-}
-
-#if 0
-static struct dm_config_node *make_int_node(struct dm_config_tree *cft,
-					    const char *key,
-					    int64_t value,
-					    struct dm_config_node *parent,
-					    struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn;
-
-	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
-	    !(cn->v = dm_config_create_value(cft)))
-		return NULL;
-
-	cn->v->type = DM_CFG_INT;
-	cn->v->v.i = value;
-	return cn;
-}
-#endif
-
 static void filter_metadata(struct dm_config_node *vg) {
 	struct dm_config_node *pv = pvs(vg);
 	while (pv) {
diff --git a/lib/config/config.c b/lib/config/config.c
index a7bda97..00bfcab 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -489,3 +489,4 @@ int config_write(struct dm_config_tree *cft, const char *file,
 
 	return r;
 }
+
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 6aad75c..0ade329 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -72,9 +72,8 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 	daemon_reply reply = { .cft = NULL, .error = 0 };
 	assert(h.socket_fd >= 0);
 
-	if (!rq.buffer) {
-		/* TODO: build the buffer from rq.cft */
-	}
+	if (!rq.buffer)
+		dm_config_write_node(rq.cft->root, buffer_line, &rq.buffer);
 
 	assert(rq.buffer);
 	if (!write_buffer(h.socket_fd, rq.buffer, strlen(rq.buffer)))
@@ -94,16 +93,19 @@ void daemon_reply_destroy(daemon_reply r) {
 	dm_free(r.buffer);
 }
 
-daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
+daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 {
 	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
 	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
-	va_list ap;
+	char *rq_line;
 
-	va_start(ap, id);
-	rq.buffer = format_buffer("request", id, ap);
-	va_end(ap);
+	rq_line = format_buffer("", "request = %s", id, NULL);
+	if (!rq_line)
+		return err;
+
+	rq.buffer = format_buffer_v(rq_line, ap);
+	dm_free(rq_line);
 
 	if (!rq.buffer)
 		return err;
@@ -114,7 +116,63 @@ daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
 	return repl;
 }
 
+daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
+{
+	va_list ap;
+	va_start(ap, id);
+	daemon_reply r = daemon_send_simple_v(h, id, ap);
+	va_end(ap);
+	return r;
+}
+
 void daemon_close(daemon_handle h)
 {
 	dm_free((char *)h.protocol);
 }
+
+daemon_request daemon_request_make(const char *id)
+{
+	daemon_request r;
+	r.cft = NULL;
+	r.buffer = NULL;
+
+	if (!(r.cft = dm_config_create()))
+		goto bad;
+
+	if (!(r.cft->root = make_text_node(r.cft, "request", id, NULL, NULL)))
+		goto bad;
+
+	return r;
+bad:
+	if (r.cft)
+		dm_config_destroy(r.cft);
+	r.cft = NULL;
+	return r;
+}
+
+int daemon_request_extend_v(daemon_request r, va_list ap)
+{
+	if (!r.cft)
+		return 0;
+
+	if (!config_make_nodes_v(r.cft, NULL, r.cft->root, ap))
+		return 0;
+
+	return 1;
+}
+
+int daemon_request_extend(daemon_request r, ...)
+{
+	va_list ap;
+	va_start(ap, r);
+	int res = daemon_request_extend_v(r, ap);
+	va_end(ap);
+	return res;
+}
+
+void daemon_request_destroy(daemon_request r) {
+	if (r.cft)
+		dm_config_destroy(r.cft);
+	dm_free(r.buffer);
+}
+
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 15fef70..2863d03 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -87,6 +87,12 @@ daemon_reply daemon_send(daemon_handle h, daemon_request r);
  * for ? in %?: d for integer, s for string.
  */
 daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...);
+daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap);
+
+daemon_request daemon_request_make(const char *id);
+int daemon_request_extend(daemon_request r, ...);
+int daemon_request_extend_v(daemon_request r, va_list ap);
+void daemon_request_destroy(daemon_request r);
 
 void daemon_reply_destroy(daemon_reply r);
 
diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index b767794..40c02b0 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -17,8 +17,8 @@
 #include <malloc.h>
 #include <string.h>
 #include <unistd.h>
-#include <assert.h>
 
+#include "dm-logging.h"
 #include "daemon-shared.h"
 #include "libdevmapper.h"
 
@@ -99,18 +99,21 @@ write:
 	goto write;
 }
 
-char *format_buffer(const char *what, const char *id, va_list ap)
+char *format_buffer_v(const char *head, va_list ap)
 {
 	char *buffer, *old;
 	char *next;
 	int keylen;
 
-	dm_asprintf(&buffer, "%s = \"%s\"\n", what, id);
+	dm_asprintf(&buffer, "%s", head);
 	if (!buffer) goto fail;
 
 	while ((next = va_arg(ap, char *))) {
 		old = buffer;
-		assert(strchr(next, '='));
+		if (!strchr(next, '=')) {
+			log_error(INTERNAL_ERROR "Bad format string at '%s'", next);
+			goto fail;
+		}
 		keylen = strchr(next, '=') - next;
 		if (strstr(next, "%d")) {
 			int value = va_arg(ap, int);
@@ -138,3 +141,224 @@ fail:
 	dm_free(buffer);
 	return NULL;
 }
+
+char *format_buffer(const char *head, ...)
+{
+	va_list ap;
+	va_start(ap, head);
+	char *res = format_buffer_v(head, ap);
+	va_end(ap);
+	return res;
+}
+
+int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
+	     const char *field, const char *flag, int want)
+{
+	struct dm_config_value *value = NULL, *pred = NULL;
+	struct dm_config_node *node = dm_config_find_node(parent->child, field);
+	struct dm_config_value *new;
+
+	if (node)
+		value = node->v;
+
+	while (value && value->type != DM_CFG_EMPTY_ARRAY && strcmp(value->v.str, flag)) {
+		pred = value;
+		value = value->next;
+	}
+
+	if (value && want)
+		return 1;
+
+	if (!value && !want)
+		return 1;
+
+	if (value && !want) {
+		if (pred) {
+			pred->next = value->next;
+		} else if (value == node->v && value->next) {
+			node->v = value->next;
+		} else {
+			node->v->type = DM_CFG_EMPTY_ARRAY;
+		}
+	}
+
+	if (!value && want) {
+		if (!node) {
+			if (!(node = dm_config_create_node(cft, field)))
+				return 0;
+			node->sib = parent->child;
+			if (!(node->v = dm_config_create_value(cft)))
+				return 0;
+			node->v->type = DM_CFG_EMPTY_ARRAY;
+			node->parent = parent;
+			parent->child = node;
+		}
+		if (!(new = dm_config_create_value(cft))) {
+			/* FIXME error reporting */
+			return 0;
+		}
+		new->type = DM_CFG_STRING;
+		new->v.str = flag;
+		new->next = node->v;
+		node->v = new;
+	}
+
+	return 1;
+}
+
+static void chain_node(struct dm_config_node *cn,
+		       struct dm_config_node *parent,
+		       struct dm_config_node *pre_sib)
+{
+	cn->parent = parent;
+	cn->sib = NULL;
+
+	if (parent && parent->child && !pre_sib) { /* find the last one */
+		pre_sib = parent->child;
+		while (pre_sib && pre_sib->sib)
+			pre_sib = pre_sib->sib;
+	}
+
+	if (parent && !parent->child)
+		parent->child = cn;
+	if (pre_sib)
+		pre_sib->sib = cn;
+
+}
+
+struct dm_config_node *make_config_node(struct dm_config_tree *cft,
+					const char *key,
+					struct dm_config_node *parent,
+					struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn;
+
+	if (!(cn = dm_config_create_node(cft, key)))
+		return NULL;
+
+	cn->v = NULL;
+	cn->child = NULL;
+
+	chain_node(cn, parent, pre_sib);
+
+	return cn;
+}
+
+struct dm_config_node *make_text_node(struct dm_config_tree *cft,
+				      const char *key,
+				      const char *value,
+				      struct dm_config_node *parent,
+				      struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn;
+
+	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
+	    !(cn->v = dm_config_create_value(cft)))
+		return NULL;
+
+	cn->v->type = DM_CFG_STRING;
+	cn->v->v.str = value;
+	return cn;
+}
+
+struct dm_config_node *make_int_node(struct dm_config_tree *cft,
+				     const char *key,
+				     int64_t value,
+				     struct dm_config_node *parent,
+				     struct dm_config_node *pre_sib)
+{
+	struct dm_config_node *cn;
+
+	if (!(cn = make_config_node(cft, key, parent, pre_sib)) ||
+	    !(cn->v = dm_config_create_value(cft)))
+		return NULL;
+
+	cn->v->type = DM_CFG_INT;
+	cn->v->v.i = value;
+	return cn;
+}
+
+struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
+					   struct dm_config_node *parent,
+					   struct dm_config_node *pre_sib,
+					   va_list ap)
+{
+	const char *next;
+	struct dm_config_node *first = NULL;
+
+	while ((next = va_arg(ap, char *))) {
+		struct dm_config_node *cn = NULL;
+		const char *fmt = strchr(next, '=');
+
+		if (!fmt) {
+			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
+			return_NULL;
+		}
+		fmt += 2;
+
+		char *key = dm_pool_strdup(cft->mem, next);
+		*strchr(key, '=') = 0;
+
+		if (!strcmp(fmt, "%d")) {
+			int64_t value = va_arg(ap, int64_t);
+			if (!(cn = make_int_node(cft, key, value, parent, pre_sib)))
+				return 0;
+		} else if (!strcmp(fmt, "%s")) {
+			char *value = va_arg(ap, char *);
+			if (!(cn = make_text_node(cft, key, value, parent, pre_sib)))
+				return 0;
+		} else if (!strcmp(fmt, "%t")) {
+			struct dm_config_tree *tree = va_arg(ap, struct dm_config_tree *);
+			cn = dm_config_clone_node(cft, tree->root, 1);
+			if (!cn)
+				return 0;
+			cn->key = key;
+			chain_node(cn, parent, pre_sib);
+		} else {
+			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
+			return_NULL;
+		}
+		if (!first)
+			first = cn;
+		if (cn)
+			pre_sib = cn;
+	}
+
+	return first;
+}
+
+struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
+					 struct dm_config_node *parent,
+					 struct dm_config_node *pre_sib,
+					 ...)
+{
+	va_list ap;
+	va_start(ap, pre_sib);
+	struct dm_config_node *res = config_make_nodes_v(cft, parent, pre_sib, ap);
+	va_end(ap);
+	return res;
+}
+
+int buffer_rewrite(char **buf, const char *format, const char *string)
+{
+	char *old = *buf;
+	int r = dm_asprintf(buf, format, *buf, string);
+
+	dm_free(old);
+
+	return (r < 0) ? 0 : 1;
+}
+
+int buffer_line(const char *line, void *baton)
+{
+	char **buffer = baton;
+
+	if (*buffer) {
+		if (!buffer_rewrite(buffer, "%s\n%s", line))
+			return 0;
+	} else if (dm_asprintf(buffer, "%s\n", line) < 0)
+		return 0;
+
+	return 1;
+}
+
diff --git a/libdaemon/client/daemon-shared.h b/libdaemon/client/daemon-shared.h
index 3e5fa9c..acb71c6 100644
--- a/libdaemon/client/daemon-shared.h
+++ b/libdaemon/client/daemon-shared.h
@@ -16,15 +16,51 @@
 #define _LVM_DAEMON_SHARED_H
 
 #include "configure.h"
+#include "libdevmapper.h"
 
 #define _REENTRANT
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
+/* TODO function names */
+
 #include <stdarg.h>
 
 int read_buffer(int fd, char **buffer);
 int write_buffer(int fd, const char *buffer, int length);
-char *format_buffer(const char *what, const char *id, va_list ap);
+char *format_buffer_v(const char *head, va_list ap);
+char *format_buffer(const char *head, ...);
+
+int buffer_line(const char *line, void *baton);
+int buffer_rewrite(char **buf, const char *format, const char *string);
+
+int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
+	     const char *field, const char *flag, int want);
+
+struct dm_config_node *make_config_node(struct dm_config_tree *cft,
+					const char *key,
+					struct dm_config_node *parent,
+					struct dm_config_node *pre_sib);
+
+struct dm_config_node *make_text_node(struct dm_config_tree *cft,
+				      const char *key,
+				      const char *value,
+				      struct dm_config_node *parent,
+				      struct dm_config_node *pre_sib);
+
+struct dm_config_node *make_int_node(struct dm_config_tree *cft,
+				     const char *key,
+				     int64_t value,
+				     struct dm_config_node *parent,
+				     struct dm_config_node *pre_sib);
+
+struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
+					   struct dm_config_node *parent,
+					   struct dm_config_node *pre_sib,
+					   va_list ap);
+struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
+					 struct dm_config_node *parent,
+					 struct dm_config_node *pre_sib,
+					 ...);
 
 #endif /* _LVM_DAEMON_SHARED_H */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index ef26cbc..76627c0 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -329,14 +329,23 @@ response daemon_reply_simple(const char *id, ...)
 {
 	va_list ap;
 	response res = { .cft = NULL };
+	char *res_line = NULL;
 
 	va_start(ap, id);
 
-	if (!(res.buffer = format_buffer("response", id, ap)))
+	if (!(res_line = format_buffer("", "response = %s", id, NULL))) {
 		res.error = ENOMEM;
+		goto end;
+	}
 
-	va_end(ap);
+	if (!(res.buffer = format_buffer_v(res_line, ap))) {
+		res.error = ENOMEM;
+		goto end;
+	}
 
+end:
+	dm_free(res_line);
+	va_end(ap);
 	return res;
 }
 
@@ -345,27 +354,6 @@ struct thread_baton {
 	client_handle client;
 };
 
-static int buffer_rewrite(char **buf, const char *format, const char *string) {
-	char *old = *buf;
-	int r = dm_asprintf(buf, format, *buf, string);
-
-	dm_free(old);
-
-	return (r < 0) ? 0 : 1;
-}
-
-static int buffer_line(const char *line, void *baton) {
-	response *r = baton;
-
-	if (r->buffer) {
-		if (!buffer_rewrite(&r->buffer, "%s\n%s", line))
-			return 0;
-	} else if (dm_asprintf(&r->buffer, "%s\n", line) < 0)
-		return 0;
-
-	return 1;
-}
-
 static response builtin_handler(daemon_state s, client_handle h, request r)
 {
 	const char *rq = daemon_request_str(r, "request", "NONE");
@@ -382,7 +370,7 @@ static response builtin_handler(daemon_state s, client_handle h, request r)
 static void *client_thread(void *baton)
 {
 	struct thread_baton *b = baton;
-	request req;
+	request req = { .buffer = NULL };
 	response res;
 
 	while (1) {
@@ -402,11 +390,9 @@ static void *client_thread(void *baton)
 			res = b->s.handler(b->s, b->client, req);
 
 		if (!res.buffer) {
-			dm_config_write_node(res.cft->root, buffer_line, &res);
-			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL)) {
-				dm_free(req.buffer);
+			dm_config_write_node(res.cft->root, buffer_line, &res.buffer);
+			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL))
 				goto fail;
-			}
 			dm_config_destroy(res.cft);
 		}
 
@@ -423,7 +409,8 @@ fail:
 	/* TODO what should we really do here? */
 	if (close(b->client.socket_fd))
 		perror("close");
-	free(baton);
+	dm_free(req.buffer);
+	dm_free(baton);
 	return NULL;
 }
 


