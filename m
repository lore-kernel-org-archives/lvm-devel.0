From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 16:15:42 +0000 (UTC)
Subject: master - libdaemon: Make buffer handling asymptotically more efficient.
Message-ID: <20121011161542.F2D552354@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b07df8850ad1952edff67f263f1f161b1d4cf439
Commit:        b07df8850ad1952edff67f263f1f161b1d4cf439
Parent:        0a46160d94524cca9d07e2d183d62ff6df1ec48e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 14:17:17 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 18:09:41 2012 +0200

libdaemon: Make buffer handling asymptotically more efficient.

---
 daemons/lvmetad/lvmetad-core.c   |   17 +++++--
 libdaemon/client/config-util.c   |   91 ++++++++++++++++++++++++--------------
 libdaemon/client/config-util.h   |   15 +++++-
 libdaemon/client/daemon-client.c |   36 ++++++---------
 libdaemon/client/daemon-client.h |    5 +-
 libdaemon/client/daemon-io.c     |   38 +++++++---------
 libdaemon/client/daemon-io.h     |    5 +-
 libdaemon/server/daemon-server.c |   35 +++++++-------
 libdaemon/server/daemon-server.h |    4 +-
 9 files changed, 140 insertions(+), 106 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8a1378a..47b07aa 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -287,7 +287,9 @@ static response pv_list(lvmetad_state *s, request r)
 	struct dm_config_node *cn = NULL, *cn_pvs;
 	struct dm_hash_node *n;
 	const char *id;
-	response res = { .buffer = NULL };
+	response res;
+
+	buffer_init( &res.buffer );
 
 	if (!(res.cft = dm_config_create()))
 		return res; /* FIXME error reporting */
@@ -313,9 +315,11 @@ static response pv_lookup(lvmetad_state *s, request r)
 {
 	const char *pvid = daemon_request_str(r, "uuid", NULL);
 	int64_t devt = daemon_request_int(r, "device", 0);
-	response res = { .buffer = NULL };
+	response res;
 	struct dm_config_node *pv;
 
+	buffer_init( &res.buffer );
+
 	if (!pvid && !devt)
 		return reply_fail("need PVID or device");
 
@@ -355,7 +359,10 @@ static response vg_list(lvmetad_state *s, request r)
 	struct dm_hash_node *n;
 	const char *id;
 	const char *name;
-	response res = { .buffer = NULL };
+	response res;
+
+	buffer_init( &res.buffer );
+
 	if (!(res.cft = dm_config_create()))
                 goto bad; /* FIXME: better error reporting */
 
@@ -422,11 +429,13 @@ static response vg_lookup(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *cft;
 	struct dm_config_node *metadata, *n;
-	response res = { .buffer = NULL };
+	response res;
 
 	const char *uuid = daemon_request_str(r, "uuid", NULL);
 	const char *name = daemon_request_str(r, "name", NULL);
 
+	buffer_init( &res.buffer );
+
 	DEBUG(s, "vg_lookup: uuid = %s, name = %s", uuid, name);
 
 	if (!uuid || !name) {
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 2573139..30fc4f8 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -21,17 +21,13 @@
 #include "config-util.h"
 #include "libdevmapper.h"
 
-char *format_buffer_v(const char *head, va_list ap)
+int buffer_append_vf(struct buffer *buf, va_list ap)
 {
-	char *buffer, *old;
+	char *append, *old;
 	char *next;
 	int keylen;
 
-	dm_asprintf(&buffer, "%s", head);
-	if (!buffer) goto fail;
-
 	while ((next = va_arg(ap, char *))) {
-		old = buffer;
 		if (!strchr(next, '=')) {
 			log_error(INTERNAL_ERROR "Bad format string at '%s'", next);
 			goto fail;
@@ -39,36 +35,34 @@ char *format_buffer_v(const char *head, va_list ap)
 		keylen = strchr(next, '=') - next;
 		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
 			int64_t value = va_arg(ap, int64_t);
-			dm_asprintf(&buffer, "%s%.*s= %" PRId64 "\n", buffer, keylen, next, value);
-			dm_free(old);
+			dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value);
 		} else if (strstr(next, "%s")) {
 			char *value = va_arg(ap, char *);
-			dm_asprintf(&buffer, "%s%.*s= \"%s\"\n", buffer, keylen, next, value);
-			dm_free(old);
+			dm_asprintf(&append, "%.*s= \"%s\"\n", keylen, next, value);
 		} else if (strstr(next, "%b")) {
 			char *block = va_arg(ap, char *);
 			if (!block)
 				continue;
-			dm_asprintf(&buffer, "%s%.*s%s", buffer, keylen, next, block);
-			dm_free(old);
+			dm_asprintf(&append, "%.*s%s", keylen, next, block);
 		} else {
-			dm_asprintf(&buffer, "%s%s", buffer, next);
-			dm_free(old);
+			dm_asprintf(&append, "%s", next);
 		}
-		if (!buffer) goto fail;
+		if (!append) goto fail;
+		buffer_append(buf, append);
+		dm_free(append);
 	}
 
-	return buffer;
+	return 1;
 fail:
-	dm_free(buffer);
-	return NULL;
+	dm_free(append);
+	return 0;
 }
 
-char *format_buffer(const char *head, ...)
+int buffer_append_f(struct buffer *buf, ...)
 {
 	va_list ap;
-	va_start(ap, head);
-	char *res = format_buffer_v(head, ap);
+	va_start(ap, buf);
+	int res = buffer_append_vf(buf, ap);
 	va_end(ap);
 	return res;
 }
@@ -263,26 +257,57 @@ struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
 	return res;
 }
 
-int buffer_rewrite(char **buf, const char *format, const char *string)
+int buffer_realloc(struct buffer *buf, int needed)
 {
-	char *old = *buf;
-	int r = dm_asprintf(buf, format, *buf, string);
+	char *new;
+	int alloc = buf->allocated;
+	if (alloc < needed)
+		alloc = needed;
+
+	buf->allocated += alloc;
+	new = realloc(buf->mem, buf->allocated);
+	if (new)
+		buf->mem = new;
+	else { /* utter failure */
+		dm_free(buf->mem);
+		buf->mem = 0;
+		buf->allocated = buf->used = 0;
+		return 0;
+	}
+	return 1;
+}
+
+int buffer_append(struct buffer *buf, const char *string)
+{
+	int len = strlen(string);
+	char *new;
 
-	dm_free(old);
+	if (buf->allocated - buf->used <= len)
+		buffer_realloc(buf, len + 1);
 
-	return (r < 0) ? 0 : 1;
+	strcpy(buf->mem + buf->used, string);
+	buf->used += len;
+	return 1;
 }
 
 int buffer_line(const char *line, void *baton)
 {
-	char **buffer = baton;
-
-	if (*buffer) {
-		if (!buffer_rewrite(buffer, "%s\n%s", line))
-			return 0;
-	} else if (dm_asprintf(buffer, "%s\n", line) < 0)
+	struct buffer *buf = baton;
+	if (!buffer_append(buf, line))
+		return 0;
+	if (!buffer_append(buf, "\n"))
 		return 0;
-
 	return 1;
 }
 
+void buffer_destroy(struct buffer *buf)
+{
+	dm_free(buf->mem);
+	buffer_init(buf);
+}
+
+void buffer_init(struct buffer *buf)
+{
+	buf->allocated = buf->used = 0;
+	buf->mem = 0;
+}
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index ae5e556..f03bcab 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -20,11 +20,20 @@
 
 #include <stdarg.h>
 
-char *format_buffer_v(const char *head, va_list ap);
-char *format_buffer(const char *head, ...);
+struct buffer {
+	int allocated;
+	int used;
+	char *mem;
+};
+
+int buffer_append_vf(struct buffer *buf, va_list ap);
+int buffer_append_f(struct buffer *buf, ...);
+int buffer_append(struct buffer *buf, const char *string);
+void buffer_init(struct buffer *buf);
+void buffer_destroy(struct buffer *buf);
+int buffer_realloc(struct buffer *buf, int required);
 
 int buffer_line(const char *line, void *baton);
-int buffer_rewrite(char **buf, const char *format, const char *string);
 
 int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
 	     const char *field, const char *flag, int want);
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index c87856c..107882b 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -73,24 +73,24 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
 	daemon_reply reply = { .cft = NULL, .error = 0 };
 	assert(h.socket_fd >= 0);
-	char *buffer = rq.buffer;
+	struct buffer buffer = rq.buffer;
 
-	if (!buffer)
+	if (!buffer.mem)
 		dm_config_write_node(rq.cft->root, buffer_line, &buffer);
 
-	assert(buffer);
-	if (!write_buffer(h.socket_fd, buffer, strlen(buffer)))
+	assert(buffer.mem);
+	if (!buffer_write(h.socket_fd, &buffer))
 		reply.error = errno;
 
-	if (read_buffer(h.socket_fd, &reply.buffer)) {
-		reply.cft = dm_config_from_string(reply.buffer);
+	if (buffer_read(h.socket_fd, &reply.buffer)) {
+		reply.cft = dm_config_from_string(reply.buffer.mem);
 		if (!reply.cft)
 			reply.error = EPROTO;
 	} else
 		reply.error = errno;
 
-	if (buffer != rq.buffer)
-		dm_free(buffer);
+	if (buffer.mem != rq.buffer.mem)
+		buffer_destroy(&buffer);
 
 	return reply;
 }
@@ -98,28 +98,22 @@ daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 void daemon_reply_destroy(daemon_reply r) {
 	if (r.cft)
 		dm_config_destroy(r.cft);
-	dm_free(r.buffer);
+	buffer_destroy(&r.buffer);
 }
 
 daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 {
-	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
+	static const daemon_reply err = { .error = ENOMEM, .buffer = { 0, 0, NULL }, .cft = NULL };
 	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
-	char *rq_line;
 
-	rq_line = format_buffer("", "request = %s", id, NULL);
-	if (!rq_line)
+	if (!buffer_append_f(&rq.buffer, "request = %s", id, NULL))
 		return err;
-
-	rq.buffer = format_buffer_v(rq_line, ap);
-	dm_free(rq_line);
-
-	if (!rq.buffer)
+	if (!buffer_append_vf(&rq.buffer, ap))
 		return err;
 
 	repl = daemon_send(h, rq);
-	dm_free(rq.buffer);
+	buffer_destroy(&rq.buffer);
 
 	return repl;
 }
@@ -142,7 +136,7 @@ daemon_request daemon_request_make(const char *id)
 {
 	daemon_request r;
 	r.cft = NULL;
-	r.buffer = NULL;
+	buffer_init(&r.buffer);
 
 	if (!(r.cft = dm_config_create()))
 		goto bad;
@@ -181,6 +175,6 @@ int daemon_request_extend(daemon_request r, ...)
 void daemon_request_destroy(daemon_request r) {
 	if (r.cft)
 		dm_config_destroy(r.cft);
-	dm_free(r.buffer);
+	buffer_destroy(&r.buffer);
 }
 
diff --git a/libdaemon/client/daemon-client.h b/libdaemon/client/daemon-client.h
index 2863d03..6ba65e6 100644
--- a/libdaemon/client/daemon-client.h
+++ b/libdaemon/client/daemon-client.h
@@ -16,6 +16,7 @@
 #define _LVM_DAEMON_COMMON_CLIENT_H
 
 #include "libdevmapper.h"
+#include "config-util.h"
 
 typedef struct {
 	int socket_fd; /* the fd we use to talk to the daemon */
@@ -38,7 +39,7 @@ typedef struct {
 } daemon_info;
 
 typedef struct {
-	char *buffer;
+	struct buffer buffer;
 	/*
 	 * The request looks like this:
 	 *    request = "id"
@@ -55,7 +56,7 @@ typedef struct {
 
 typedef struct {
 	int error; /* 0 for success */
-	char *buffer; /* textual reply */
+	struct buffer buffer;
 	struct dm_config_tree *cft; /* parsed reply, if available */
 } daemon_reply;
 
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 4af9343..50ef9b2 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -29,26 +29,22 @@
  *
  * See also write_buffer about blocking (read_buffer has identical behaviour).
  */
-int read_buffer(int fd, char **buffer) {
-	int bytes = 0;
-	int buffersize = 32;
-	char *new;
-	*buffer = dm_malloc(buffersize + 1);
+int buffer_read(int fd, struct buffer *buffer) {
+	if (!buffer_realloc(buffer, 32)) /* ensure we have some space */
+		goto fail;
 
 	while (1) {
-		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
+		int result = read(fd, buffer->mem + buffer->used, buffer->allocated - buffer->used);
 		if (result > 0) {
-			bytes += result;
-			if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
-				*(*buffer + bytes - 4) = 0;
+			buffer->used += result;
+			if (!strncmp((buffer->mem) + buffer->used - 4, "\n##\n", 4)) {
+				*(buffer->mem + buffer->used - 4) = 0;
+				buffer->used -= 4;
 				break; /* success, we have the full message now */
 			}
-			if (bytes == buffersize) {
-				buffersize += 1024;
-				if (!(new = realloc(*buffer, buffersize + 1)))
+			if (buffer->used - buffer->allocated < 32)
+				if (!buffer_realloc(buffer, 1024))
 					goto fail;
-				*buffer = new;
-			}
 			continue;
 		}
 		if (result == 0) {
@@ -61,8 +57,6 @@ int read_buffer(int fd, char **buffer) {
 	}
 	return 1;
 fail:
-	dm_free(*buffer);
-	*buffer = NULL;
 	return 0;
 }
 
@@ -72,18 +66,19 @@ fail:
  *
  * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
  */
-int write_buffer(int fd, const char *buffer, int length) {
-	static const char terminate[] = "\n##\n";
+int buffer_write(int fd, struct buffer *buffer) {
+	struct buffer terminate = { .mem = (char *) "\n##\n", .used = 4 };
 	int done = 0;
 	int written = 0;
+	struct buffer *use = buffer;
 write:
 	while (1) {
-		int result = write(fd, buffer + written, length - written);
+		int result = write(fd, use->mem + written, use->used - written);
 		if (result > 0)
 			written += result;
 		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
 			return 0; /* too bad */
-		if (written == length) {
+		if (written == use->used) {
 			if (done)
 				return 1;
 			else
@@ -91,8 +86,7 @@ write:
 		}
 	}
 
-	buffer = terminate;
-	length = 4;
+	use = &terminate;
 	written = 0;
 	done = 1;
 	goto write;
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
index e6e5f06..1f55af7 100644
--- a/libdaemon/client/daemon-io.h
+++ b/libdaemon/client/daemon-io.h
@@ -16,6 +16,7 @@
 #define _LVM_DAEMON_IO_H
 
 #include "configure.h"
+#include "config-util.h"
 #include "libdevmapper.h"
 
 #define _REENTRANT
@@ -24,7 +25,7 @@
 
 /* TODO function names */
 
-int read_buffer(int fd, char **buffer);
-int write_buffer(int fd, const char *buffer, int length);
+int buffer_read(int fd, struct buffer *buffer);
+int buffer_write(int fd, struct buffer *buffer);
 
 #endif /* _LVM_DAEMON_SHARED_H */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 9dd911f..051e7c2 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -330,22 +330,20 @@ response daemon_reply_simple(const char *id, ...)
 {
 	va_list ap;
 	response res = { .cft = NULL };
-	char *res_line = NULL;
 
 	va_start(ap, id);
 
-	if (!(res_line = format_buffer("", "response = %s", id, NULL))) {
+	buffer_init(&res.buffer);
+	if (!buffer_append_f(&res.buffer, "response = %s", id, NULL)) {
 		res.error = ENOMEM;
 		goto end;
 	}
-
-	if (!(res.buffer = format_buffer_v(res_line, ap))) {
+	if (!buffer_append_vf(&res.buffer, ap)) {
 		res.error = ENOMEM;
 		goto end;
 	}
 
 end:
-	dm_free(res_line);
 	va_end(ap);
 	return res;
 }
@@ -364,24 +362,27 @@ static response builtin_handler(daemon_state s, client_handle h, request r)
 					   "version = %" PRId64, (int64_t) s.protocol_version, NULL);
 	}
 
-	response res = { .buffer = NULL, .error = EPROTO };
+	response res = { .error = EPROTO };
+	buffer_init(&res.buffer);
 	return res;
 }
 
 static void *client_thread(void *baton)
 {
 	struct thread_baton *b = baton;
-	request req = { .buffer = NULL };
+	request req;
 	response res;
 
+	buffer_init(&req.buffer);
+
 	while (1) {
-		if (!read_buffer(b->client.socket_fd, &req.buffer))
+		if (!buffer_read(b->client.socket_fd, &req.buffer))
 			goto fail;
 
-		req.cft = dm_config_from_string(req.buffer);
+		req.cft = dm_config_from_string(req.buffer.mem);
 
 		if (!req.cft)
-			fprintf(stderr, "error parsing request:\n %s\n", req.buffer);
+			fprintf(stderr, "error parsing request:\n %s\n", req.buffer.mem);
 		else
 			daemon_log_cft(b->s.log, DAEMON_LOG_WIRE, "<- ", req.cft->root);
 
@@ -390,27 +391,27 @@ static void *client_thread(void *baton)
 		if (res.error == EPROTO) /* Not a builtin, delegate to the custom handler. */
 			res = b->s.handler(b->s, b->client, req);
 
-		if (!res.buffer) {
+		if (!res.buffer.mem) {
 			dm_config_write_node(res.cft->root, buffer_line, &res.buffer);
-			if (!buffer_rewrite(&res.buffer, "%s\n\n", NULL))
+			if (!buffer_append(&res.buffer, "\n\n"))
 				goto fail;
 			dm_config_destroy(res.cft);
 		}
 
 		if (req.cft)
 			dm_config_destroy(req.cft);
-		dm_free(req.buffer);
+		buffer_destroy(&req.buffer);
 
-		daemon_log_multi(b->s.log, DAEMON_LOG_WIRE, "-> ", res.buffer);
-		write_buffer(b->client.socket_fd, res.buffer, strlen(res.buffer));
+		daemon_log_multi(b->s.log, DAEMON_LOG_WIRE, "-> ", res.buffer.mem);
+		buffer_write(b->client.socket_fd, &res.buffer);
 
-		free(res.buffer);
+		buffer_destroy(&res.buffer);
 	}
 fail:
 	/* TODO what should we really do here? */
 	if (close(b->client.socket_fd))
 		perror("close");
-	dm_free(req.buffer);
+	buffer_destroy(&req.buffer);
 	dm_free(baton);
 	return NULL;
 }
diff --git a/libdaemon/server/daemon-server.h b/libdaemon/server/daemon-server.h
index df7ed8e..2109602 100644
--- a/libdaemon/server/daemon-server.h
+++ b/libdaemon/server/daemon-server.h
@@ -26,13 +26,13 @@ typedef struct {
 
 typedef struct {
 	struct dm_config_tree *cft;
-	char *buffer;
+	struct buffer buffer;
 } request;
 
 typedef struct {
 	int error;
 	struct dm_config_tree *cft;
-	char *buffer;
+	struct buffer buffer;
 } response;
 
 struct daemon_state;


