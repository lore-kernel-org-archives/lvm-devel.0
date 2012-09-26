From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:19 +0000 (UTC)
Subject: master - libdaemon: Split daemon-shared.[hc] into daemon-io.[hc] and config-util.[hc].
Message-ID: <20120926175619.AD271A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=662a2122f6224b5404d9f1276868bc3069766c49
Commit:        662a2122f6224b5404d9f1276868bc3069766c49
Parent:        4ece923a4b8a38fd794ac1cc83d887747db6edda
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 26 14:44:03 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

libdaemon: Split daemon-shared.[hc] into daemon-io.[hc] and config-util.[hc].

---
 daemons/lvmetad/lvmetad-core.c   |    3 +-
 include/.symlinks.in             |    3 +-
 lib/cache/lvmetad.h              |    2 +-
 libdaemon/client/Makefile.in     |    2 +-
 libdaemon/client/config-util.c   |  288 ++++++++++++++++++++++++++++++
 libdaemon/client/config-util.h   |   58 ++++++
 libdaemon/client/daemon-client.c |    4 +-
 libdaemon/client/daemon-io.c     |   99 ++++++++++
 libdaemon/client/daemon-io.h     |   30 +++
 libdaemon/client/daemon-shared.c |  365 --------------------------------------
 libdaemon/client/daemon-shared.h |   66 -------
 libdaemon/server/daemon-server.c |    3 +-
 12 files changed, 486 insertions(+), 437 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 6c2303d..0c39a77 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -15,7 +15,8 @@
 #define _XOPEN_SOURCE 500  /* pthread */
 
 #include "configure.h"
-#include "daemon-shared.h"
+#include "daemon-io.h"
+#include "config-util.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 
diff --git a/include/.symlinks.in b/include/.symlinks.in
index bd0eba7..e94ff84 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -61,7 +61,8 @@
 @top_srcdir@/lib/report/report.h
 @top_srcdir@/lib/uuid/uuid.h
 @top_srcdir@/libdaemon/client/daemon-client.h
- at top_srcdir@/libdaemon/client/daemon-shared.h
+ at top_srcdir@/libdaemon/client/daemon-io.h
+ at top_srcdir@/libdaemon/client/config-util.h
 @top_srcdir@/libdm/libdevmapper.h
 @top_srcdir@/libdm/misc/dm-ioctl.h
 @top_srcdir@/libdm/misc/dm-logging.h
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 60110a0..10c4b13 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -15,7 +15,7 @@
 #ifndef _LVM_METAD_H
 #define _LVM_METAD_H
 
-#include "daemon-shared.h" // XXX
+#include "config-util.h"
 
 struct volume_group;
 struct cmd_context;
diff --git a/libdaemon/client/Makefile.in b/libdaemon/client/Makefile.in
index 4d8c436..d608816 100644
--- a/libdaemon/client/Makefile.in
+++ b/libdaemon/client/Makefile.in
@@ -15,6 +15,6 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 LIB_STATIC = libdaemonclient.a
-SOURCES = daemon-shared.c daemon-client.c
+SOURCES = daemon-io.c config-util.c daemon-client.c
 
 include $(top_builddir)/make.tmpl
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
new file mode 100644
index 0000000..2573139
--- /dev/null
+++ b/libdaemon/client/config-util.c
@@ -0,0 +1,288 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#include "dm-logging.h"
+#include "config-util.h"
+#include "libdevmapper.h"
+
+char *format_buffer_v(const char *head, va_list ap)
+{
+	char *buffer, *old;
+	char *next;
+	int keylen;
+
+	dm_asprintf(&buffer, "%s", head);
+	if (!buffer) goto fail;
+
+	while ((next = va_arg(ap, char *))) {
+		old = buffer;
+		if (!strchr(next, '=')) {
+			log_error(INTERNAL_ERROR "Bad format string at '%s'", next);
+			goto fail;
+		}
+		keylen = strchr(next, '=') - next;
+		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
+			int64_t value = va_arg(ap, int64_t);
+			dm_asprintf(&buffer, "%s%.*s= %" PRId64 "\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%s")) {
+			char *value = va_arg(ap, char *);
+			dm_asprintf(&buffer, "%s%.*s= \"%s\"\n", buffer, keylen, next, value);
+			dm_free(old);
+		} else if (strstr(next, "%b")) {
+			char *block = va_arg(ap, char *);
+			if (!block)
+				continue;
+			dm_asprintf(&buffer, "%s%.*s%s", buffer, keylen, next, block);
+			dm_free(old);
+		} else {
+			dm_asprintf(&buffer, "%s%s", buffer, next);
+			dm_free(old);
+		}
+		if (!buffer) goto fail;
+	}
+
+	return buffer;
+fail:
+	dm_free(buffer);
+	return NULL;
+}
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
+	if (pre_sib) {
+		cn->sib = pre_sib->sib;
+		pre_sib->sib = cn;
+	}
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
+		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
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
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
new file mode 100644
index 0000000..ae5e556
--- /dev/null
+++ b/libdaemon/client/config-util.h
@@ -0,0 +1,58 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_CONFIG_UTIL_H
+#define _LVM_DAEMON_CONFIG_UTIL_H
+
+#include "configure.h"
+#include "libdevmapper.h"
+
+#include <stdarg.h>
+
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
+
+#endif /* _LVM_DAEMON_SHARED_H */
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 2de970a..e34a2a0 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -12,8 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "daemon-shared.h"
+#include "daemon-io.h"
+#include "config-util.h"
 #include "daemon-client.h"
+#include "dm-logging.h"
 
 #include <sys/un.h>
 #include <sys/socket.h>
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
new file mode 100644
index 0000000..4af9343
--- /dev/null
+++ b/libdaemon/client/daemon-io.c
@@ -0,0 +1,99 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#include "daemon-io.h"
+#include "dm-logging.h"
+#include "libdevmapper.h"
+
+/*
+ * Read a single message from a (socket) filedescriptor. Messages are delimited
+ * by blank lines. This call will block until all of a message is received. The
+ * memory will be allocated from heap. Upon error, all memory is freed and the
+ * buffer pointer is set to NULL.
+ *
+ * See also write_buffer about blocking (read_buffer has identical behaviour).
+ */
+int read_buffer(int fd, char **buffer) {
+	int bytes = 0;
+	int buffersize = 32;
+	char *new;
+	*buffer = dm_malloc(buffersize + 1);
+
+	while (1) {
+		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
+		if (result > 0) {
+			bytes += result;
+			if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
+				*(*buffer + bytes - 4) = 0;
+				break; /* success, we have the full message now */
+			}
+			if (bytes == buffersize) {
+				buffersize += 1024;
+				if (!(new = realloc(*buffer, buffersize + 1)))
+					goto fail;
+				*buffer = new;
+			}
+			continue;
+		}
+		if (result == 0) {
+			errno = ECONNRESET;
+			goto fail; /* we should never encounter EOF here */
+		}
+		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
+			goto fail;
+		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK/EINTR */
+	}
+	return 1;
+fail:
+	dm_free(*buffer);
+	*buffer = NULL;
+	return 0;
+}
+
+/*
+ * Write a buffer to a filedescriptor. Keep trying. Blocks (even on
+ * SOCK_NONBLOCK) until all of the write went through.
+ *
+ * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
+ */
+int write_buffer(int fd, const char *buffer, int length) {
+	static const char terminate[] = "\n##\n";
+	int done = 0;
+	int written = 0;
+write:
+	while (1) {
+		int result = write(fd, buffer + written, length - written);
+		if (result > 0)
+			written += result;
+		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
+			return 0; /* too bad */
+		if (written == length) {
+			if (done)
+				return 1;
+			else
+				break; /* done */
+		}
+	}
+
+	buffer = terminate;
+	length = 4;
+	written = 0;
+	done = 1;
+	goto write;
+}
diff --git a/libdaemon/client/daemon-io.h b/libdaemon/client/daemon-io.h
new file mode 100644
index 0000000..e6e5f06
--- /dev/null
+++ b/libdaemon/client/daemon-io.h
@@ -0,0 +1,30 @@
+/*
+ * Copyright (C) 2011-2012 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_DAEMON_IO_H
+#define _LVM_DAEMON_IO_H
+
+#include "configure.h"
+#include "libdevmapper.h"
+
+#define _REENTRANT
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+/* TODO function names */
+
+int read_buffer(int fd, char **buffer);
+int write_buffer(int fd, const char *buffer, int length);
+
+#endif /* _LVM_DAEMON_SHARED_H */
diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
deleted file mode 100644
index e6f17a0..0000000
--- a/libdaemon/client/daemon-shared.c
+++ /dev/null
@@ -1,365 +0,0 @@
-/*
- * Copyright (C) 2011-2012 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#include <errno.h>
-#include <stdio.h>
-#include <string.h>
-#include <unistd.h>
-
-#include "dm-logging.h"
-#include "daemon-shared.h"
-#include "libdevmapper.h"
-
-/*
- * Read a single message from a (socket) filedescriptor. Messages are delimited
- * by blank lines. This call will block until all of a message is received. The
- * memory will be allocated from heap. Upon error, all memory is freed and the
- * buffer pointer is set to NULL.
- *
- * See also write_buffer about blocking (read_buffer has identical behaviour).
- */
-int read_buffer(int fd, char **buffer) {
-	int bytes = 0;
-	int buffersize = 32;
-	char *new;
-	*buffer = dm_malloc(buffersize + 1);
-
-	while (1) {
-		int result = read(fd, (*buffer) + bytes, buffersize - bytes);
-		if (result > 0) {
-			bytes += result;
-			if (!strncmp((*buffer) + bytes - 4, "\n##\n", 4)) {
-				*(*buffer + bytes - 4) = 0;
-				break; /* success, we have the full message now */
-			}
-			if (bytes == buffersize) {
-				buffersize += 1024;
-				if (!(new = realloc(*buffer, buffersize + 1)))
-					goto fail;
-				*buffer = new;
-			}
-			continue;
-		}
-		if (result == 0) {
-			errno = ECONNRESET;
-			goto fail; /* we should never encounter EOF here */
-		}
-		if (result < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
-			goto fail;
-		/* TODO call select here if we encountered EAGAIN/EWOULDBLOCK/EINTR */
-	}
-	return 1;
-fail:
-	dm_free(*buffer);
-	*buffer = NULL;
-	return 0;
-}
-
-/*
- * Write a buffer to a filedescriptor. Keep trying. Blocks (even on
- * SOCK_NONBLOCK) until all of the write went through.
- *
- * TODO use select on EWOULDBLOCK/EAGAIN/EINTR to avoid useless spinning
- */
-int write_buffer(int fd, const char *buffer, int length) {
-	static const char terminate[] = "\n##\n";
-	int done = 0;
-	int written = 0;
-write:
-	while (1) {
-		int result = write(fd, buffer + written, length - written);
-		if (result > 0)
-			written += result;
-		if (result < 0 && errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR)
-			return 0; /* too bad */
-		if (written == length) {
-			if (done)
-				return 1;
-			else
-				break; /* done */
-		}
-	}
-
-	buffer = terminate;
-	length = 4;
-	written = 0;
-	done = 1;
-	goto write;
-}
-
-char *format_buffer_v(const char *head, va_list ap)
-{
-	char *buffer, *old;
-	char *next;
-	int keylen;
-
-	dm_asprintf(&buffer, "%s", head);
-	if (!buffer) goto fail;
-
-	while ((next = va_arg(ap, char *))) {
-		old = buffer;
-		if (!strchr(next, '=')) {
-			log_error(INTERNAL_ERROR "Bad format string@'%s'", next);
-			goto fail;
-		}
-		keylen = strchr(next, '=') - next;
-		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
-			int64_t value = va_arg(ap, int64_t);
-			dm_asprintf(&buffer, "%s%.*s= %" PRId64 "\n", buffer, keylen, next, value);
-			dm_free(old);
-		} else if (strstr(next, "%s")) {
-			char *value = va_arg(ap, char *);
-			dm_asprintf(&buffer, "%s%.*s= \"%s\"\n", buffer, keylen, next, value);
-			dm_free(old);
-		} else if (strstr(next, "%b")) {
-			char *block = va_arg(ap, char *);
-			if (!block)
-				continue;
-			dm_asprintf(&buffer, "%s%.*s%s", buffer, keylen, next, block);
-			dm_free(old);
-		} else {
-			dm_asprintf(&buffer, "%s%s", buffer, next);
-			dm_free(old);
-		}
-		if (!buffer) goto fail;
-	}
-
-	return buffer;
-fail:
-	dm_free(buffer);
-	return NULL;
-}
-
-char *format_buffer(const char *head, ...)
-{
-	va_list ap;
-	va_start(ap, head);
-	char *res = format_buffer_v(head, ap);
-	va_end(ap);
-	return res;
-}
-
-int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
-	     const char *field, const char *flag, int want)
-{
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
-static void chain_node(struct dm_config_node *cn,
-		       struct dm_config_node *parent,
-		       struct dm_config_node *pre_sib)
-{
-	cn->parent = parent;
-	cn->sib = NULL;
-
-	if (parent && parent->child && !pre_sib) { /* find the last one */
-		pre_sib = parent->child;
-		while (pre_sib && pre_sib->sib)
-			pre_sib = pre_sib->sib;
-	}
-
-	if (parent && !parent->child)
-		parent->child = cn;
-	if (pre_sib) {
-		cn->sib = pre_sib->sib;
-		pre_sib->sib = cn;
-	}
-
-}
-
-struct dm_config_node *make_config_node(struct dm_config_tree *cft,
-					const char *key,
-					struct dm_config_node *parent,
-					struct dm_config_node *pre_sib)
-{
-	struct dm_config_node *cn;
-
-	if (!(cn = dm_config_create_node(cft, key)))
-		return NULL;
-
-	cn->v = NULL;
-	cn->child = NULL;
-
-	chain_node(cn, parent, pre_sib);
-
-	return cn;
-}
-
-struct dm_config_node *make_text_node(struct dm_config_tree *cft,
-				      const char *key,
-				      const char *value,
-				      struct dm_config_node *parent,
-				      struct dm_config_node *pre_sib)
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
-struct dm_config_node *make_int_node(struct dm_config_tree *cft,
-				     const char *key,
-				     int64_t value,
-				     struct dm_config_node *parent,
-				     struct dm_config_node *pre_sib)
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
-
-struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
-					   struct dm_config_node *parent,
-					   struct dm_config_node *pre_sib,
-					   va_list ap)
-{
-	const char *next;
-	struct dm_config_node *first = NULL;
-
-	while ((next = va_arg(ap, char *))) {
-		struct dm_config_node *cn = NULL;
-		const char *fmt = strchr(next, '=');
-
-		if (!fmt) {
-			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
-			return_NULL;
-		}
-		fmt += 2;
-
-		char *key = dm_pool_strdup(cft->mem, next);
-		*strchr(key, '=') = 0;
-
-		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
-			int64_t value = va_arg(ap, int64_t);
-			if (!(cn = make_int_node(cft, key, value, parent, pre_sib)))
-				return 0;
-		} else if (!strcmp(fmt, "%s")) {
-			char *value = va_arg(ap, char *);
-			if (!(cn = make_text_node(cft, key, value, parent, pre_sib)))
-				return 0;
-		} else if (!strcmp(fmt, "%t")) {
-			struct dm_config_tree *tree = va_arg(ap, struct dm_config_tree *);
-			cn = dm_config_clone_node(cft, tree->root, 1);
-			if (!cn)
-				return 0;
-			cn->key = key;
-			chain_node(cn, parent, pre_sib);
-		} else {
-			log_error(INTERNAL_ERROR "Bad format string '%s'", fmt);
-			return_NULL;
-		}
-		if (!first)
-			first = cn;
-		if (cn)
-			pre_sib = cn;
-	}
-
-	return first;
-}
-
-struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
-					 struct dm_config_node *parent,
-					 struct dm_config_node *pre_sib,
-					 ...)
-{
-	va_list ap;
-	va_start(ap, pre_sib);
-	struct dm_config_node *res = config_make_nodes_v(cft, parent, pre_sib, ap);
-	va_end(ap);
-	return res;
-}
-
-int buffer_rewrite(char **buf, const char *format, const char *string)
-{
-	char *old = *buf;
-	int r = dm_asprintf(buf, format, *buf, string);
-
-	dm_free(old);
-
-	return (r < 0) ? 0 : 1;
-}
-
-int buffer_line(const char *line, void *baton)
-{
-	char **buffer = baton;
-
-	if (*buffer) {
-		if (!buffer_rewrite(buffer, "%s\n%s", line))
-			return 0;
-	} else if (dm_asprintf(buffer, "%s\n", line) < 0)
-		return 0;
-
-	return 1;
-}
-
diff --git a/libdaemon/client/daemon-shared.h b/libdaemon/client/daemon-shared.h
deleted file mode 100644
index acb71c6..0000000
--- a/libdaemon/client/daemon-shared.h
+++ /dev/null
@@ -1,66 +0,0 @@
-/*
- * Copyright (C) 2011-2012 Red Hat, Inc.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#ifndef _LVM_DAEMON_SHARED_H
-#define _LVM_DAEMON_SHARED_H
-
-#include "configure.h"
-#include "libdevmapper.h"
-
-#define _REENTRANT
-#define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
-
-/* TODO function names */
-
-#include <stdarg.h>
-
-int read_buffer(int fd, char **buffer);
-int write_buffer(int fd, const char *buffer, int length);
-char *format_buffer_v(const char *head, va_list ap);
-char *format_buffer(const char *head, ...);
-
-int buffer_line(const char *line, void *baton);
-int buffer_rewrite(char **buf, const char *format, const char *string);
-
-int set_flag(struct dm_config_tree *cft, struct dm_config_node *parent,
-	     const char *field, const char *flag, int want);
-
-struct dm_config_node *make_config_node(struct dm_config_tree *cft,
-					const char *key,
-					struct dm_config_node *parent,
-					struct dm_config_node *pre_sib);
-
-struct dm_config_node *make_text_node(struct dm_config_tree *cft,
-				      const char *key,
-				      const char *value,
-				      struct dm_config_node *parent,
-				      struct dm_config_node *pre_sib);
-
-struct dm_config_node *make_int_node(struct dm_config_tree *cft,
-				     const char *key,
-				     int64_t value,
-				     struct dm_config_node *parent,
-				     struct dm_config_node *pre_sib);
-
-struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
-					   struct dm_config_node *parent,
-					   struct dm_config_node *pre_sib,
-					   va_list ap);
-struct dm_config_node *config_make_nodes(struct dm_config_tree *cft,
-					 struct dm_config_node *parent,
-					 struct dm_config_node *pre_sib,
-					 ...);
-
-#endif /* _LVM_DAEMON_SHARED_H */
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 50bf065..b15a7cc 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -10,7 +10,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "daemon-shared.h"
+#include "daemon-io.h"
+#include "config-util.h"
 #include "daemon-server.h"
 #include "daemon-log.h"
 


