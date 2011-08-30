From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Aug 2011 14:55:25 -0000
Subject: LVM2 libdm/Makefile.in libdm/libdevmapper.h li ...
Message-ID: <20110830145525.7534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-30 14:55:19

Modified files:
	libdm          : Makefile.in libdevmapper.h libdm-string.c 
	lib/activate   : activate.c dev_manager.c 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : config.c config.h 
	lib/device     : dev-cache.c 
	lib/filters    : filter-persistent.c filter-persistent.h 
	                 filter-regex.c filter-regex.h filter.c filter.h 
	lib/format_text: export.c flags.c format-text.c import-export.h 
	                 import.c import_vsn1.c tags.c text_export.h 
	                 text_import.h 
	lib/locking    : cluster_locking.c external_locking.c 
	lib/metadata   : lv_manip.c metadata.c metadata.h mirror.c 
	                 segtype.h 
	lib/mirror     : mirrored.c 
	lib/misc       : lvm-string.c lvm-string.h 
	lib/mm         : memlock.c 
	lib/raid       : raid.c 
	lib/replicator : replicator.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/thin       : thin.c 
	lib/unknown    : unknown.c 
	tools          : dumpconfig.c pvchange.c pvck.c pvcreate.c 
	                 pvmove.c pvremove.c toollib.c vgsplit.c 
Added files:
	libdm          : libdm-config.c 

Log message:
	Move the core of the lib/config/config.c functionality into libdevmapper,
	leaving behind the LVM-specific parts of the code (convenience wrappers that
	handle `struct device` and `struct cmd_context`, basically). A number of
	functions have been renamed (in addition to getting a dm_ prefix) -- namely,
	all of the config interface now has a dm_config_ prefix.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.211&r2=1.212
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.230&r2=1.231
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/tags.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_export.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_import.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.276&r2=1.277
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.465&r2=1.466
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.249&r2=1.250
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-string.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

/cvs/lvm2/LVM2/libdm/libdm-config.c,v  -->  standard output
revision 1.1
--- LVM2/libdm/libdm-config.c
+++ -	2011-08-30 14:55:19.479999000 +0000
@@ -0,0 +1,1237 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
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
+#include "dmlib.h"
+
+#include <sys/stat.h>
+#include <sys/mman.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <ctype.h>
+
+#define SECTION_B_CHAR '{'
+#define SECTION_E_CHAR '}'
+
+enum {
+	TOK_INT,
+	TOK_FLOAT,
+	TOK_STRING,		/* Single quotes */
+	TOK_STRING_ESCAPED,	/* Double quotes */
+	TOK_EQ,
+	TOK_SECTION_B,
+	TOK_SECTION_E,
+	TOK_ARRAY_B,
+	TOK_ARRAY_E,
+	TOK_IDENTIFIER,
+	TOK_COMMA,
+	TOK_EOF
+};
+
+struct parser {
+	const char *fb, *fe;		/* file limits */
+
+	int t;			/* token limits and type */
+	const char *tb, *te;
+
+	int line;		/* line number we are on */
+
+	struct dm_pool *mem;
+};
+
+struct cs {
+	struct dm_config_tree cft;
+	struct dm_pool *mem;
+	time_t timestamp;
+	off_t st_size;
+	char *filename;
+	int exists;
+	int keep_open;
+	void *custom; /* LVM uses this for a device pointer */
+};
+
+struct output_line {
+	FILE *fp;
+	struct dm_pool *mem;
+	dm_putline_fn putline;
+	void *putline_baton;
+};
+
+static void _get_token(struct parser *p, int tok_prev);
+static void _eat_space(struct parser *p);
+static struct dm_config_node *_file(struct parser *p);
+static struct dm_config_node *_section(struct parser *p);
+static struct dm_config_value *_value(struct parser *p);
+static struct dm_config_value *_type(struct parser *p);
+static int _match_aux(struct parser *p, int t);
+static struct dm_config_value *_create_value(struct dm_pool *mem);
+static struct dm_config_node *_create_node(struct dm_pool *mem);
+static char *_dup_tok(struct parser *p);
+
+static const int sep = '/';
+
+#define MAX_INDENT 32
+
+#define match(t) do {\
+   if (!_match_aux(p, (t))) {\
+	log_error("Parse error at byte %" PRIptrdiff_t " (line %d): unexpected token", \
+		  p->tb - p->fb + 1, p->line); \
+      return 0;\
+   } \
+} while(0);
+
+static int _tok_match(const char *str, const char *b, const char *e)
+{
+	while (*str && (b != e)) {
+		if (*str++ != *b++)
+			return 0;
+	}
+
+	return !(*str || (b != e));
+}
+
+/*
+ * public interface
+ */
+struct dm_config_tree *dm_config_create(const char *filename, int keep_open)
+{
+	struct cs *c;
+	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);
+
+	if (!mem) {
+		log_error("Failed to allocate config pool.");
+		return 0;
+	}
+
+	if (!(c = dm_pool_zalloc(mem, sizeof(*c)))) {
+		log_error("Failed to allocate config tree.");
+		dm_pool_destroy(mem);
+		return 0;
+	}
+
+	c->mem = mem;
+	c->cft.root = (struct dm_config_node *) NULL;
+	c->cft.cascade = NULL;
+	c->timestamp = 0;
+	c->exists = 0;
+	c->keep_open = keep_open;
+	c->custom = NULL;
+	if (filename)
+		c->filename = dm_pool_strdup(c->mem, filename);
+	return &c->cft;
+}
+
+void dm_config_set_custom(struct dm_config_tree *cft, void *custom)
+{
+	struct cs *c = (struct cs *) cft;
+	c->custom = custom;
+}
+
+void *dm_config_get_custom(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return c->custom;
+}
+
+int dm_config_keep_open(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return c->keep_open;
+}
+
+void dm_config_destroy(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	dm_pool_destroy(c->mem);
+}
+
+int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
+{
+	/* TODO? if (start == end) return 1; */
+
+	struct cs *c = (struct cs *) cft;
+	struct parser *p;
+	if (!(p = dm_pool_alloc(c->mem, sizeof(*p))))
+		return_0;
+
+	p->mem = c->mem;
+	p->fb = start;
+	p->fe = end;
+	p->tb = p->te = p->fb;
+	p->line = 1;
+
+	_get_token(p, TOK_SECTION_E);
+	if (!(cft->root = _file(p)))
+		return_0;
+
+	return 1;
+}
+
+struct dm_config_tree *dm_config_from_string(const char *config_settings)
+{
+	struct dm_config_tree *cft;
+
+	if (!(cft = dm_config_create(NULL, 0)))
+		return_NULL;
+
+	if (!dm_config_parse(cft, config_settings, config_settings + strlen(config_settings))) {
+		dm_config_destroy(cft);
+		return_NULL;
+	}
+
+	return cft;
+}
+
+int dm_config_check_file(struct dm_config_tree *cft, const char **filename, struct stat *info)
+{
+	struct cs *c = (struct cs *) cft;
+	struct stat _info;
+	if (!info)
+		info = &_info;
+	if (filename)
+		*filename = c->filename;
+
+	if (stat(c->filename, info)) {
+		log_sys_error("stat", c->filename);
+		c->exists = 0;
+		return 0;
+	}
+
+	if (!S_ISREG(info->st_mode)) {
+		log_error("%s is not a regular file", c->filename);
+		c->exists = 0;
+		return 0;
+	}
+
+	c->exists = 1;
+
+	if (info->st_size == 0)
+		log_verbose("%s is empty", c->filename);
+
+	c->timestamp = info->st_ctime;
+	c->st_size = info->st_size;
+
+	return 1;
+}
+
+time_t dm_config_timestamp(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return c->timestamp;
+}
+
+/*
+ * Return 1 if config files ought to be reloaded
+ */
+int dm_config_changed(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	struct stat info;
+
+	if (!c->filename)
+		return 0;
+
+	if (stat(c->filename, &info) == -1) {
+		/* Ignore a deleted config file: still use original data */
+		if (errno == ENOENT) {
+			if (!c->exists)
+				return 0;
+			log_very_verbose("Config file %s has disappeared!",
+					 c->filename);
+			goto reload;
+		}
+		log_sys_error("stat", c->filename);
+		log_error("Failed to reload configuration files");
+		return 0;
+	}
+
+	if (!S_ISREG(info.st_mode)) {
+		log_error("Configuration file %s is not a regular file",
+			  c->filename);
+		goto reload;
+	}
+
+	/* Unchanged? */
+	if (c->timestamp == info.st_ctime && c->st_size == info.st_size)
+		return 0;
+
+      reload:
+	log_verbose("Detected config file change to %s", c->filename);
+	return 1;
+}
+
+static int _line_start(struct output_line *outline)
+{
+	if (!dm_pool_begin_object(outline->mem, 128)) {
+		log_error("dm_pool_begin_object failed for config line");
+		return 0;
+	}
+
+	return 1;
+}
+
+static int _line_append(struct output_line *outline, const char *fmt, ...)
+  __attribute__ ((format(printf, 2, 3)));
+static int _line_append(struct output_line *outline, const char *fmt, ...)
+{
+	char buf[4096];
+	va_list ap;
+	int n;
+
+	va_start(ap, fmt);
+	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
+	va_end(ap);
+
+	if (n < 0 || n > (int) sizeof buf - 1) {
+		log_error("vsnprintf failed for config line");
+		return 0;
+	}
+
+	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
+		log_error("dm_pool_grow_object failed for config line");
+		return 0;
+	}
+
+	return 1;
+}
+
+#define line_append(args...) do {if (!_line_append(outline, args)) {return_0;}} while (0)
+
+static int _line_end(struct output_line *outline)
+{
+	const char *line;
+
+	if (!dm_pool_grow_object(outline->mem, "\0", 1)) {
+		log_error("dm_pool_grow_object failed for config line");
+		return 0;
+	}
+
+	line = dm_pool_end_object(outline->mem);
+	if (outline->putline)
+		outline->putline(line, outline->putline_baton);
+	else {
+		if (!outline->fp)
+			log_print("%s", line);
+		else
+			fprintf(outline->fp, "%s\n", line);
+	}
+
+	return 1;
+}
+
+static int _write_value(struct output_line *outline, const struct dm_config_value *v)
+{
+	char *buf;
+
+	switch (v->type) {
+	case DM_CFG_STRING:
+		if (!(buf = alloca(dm_escaped_len(v->v.str)))) {
+			log_error("temporary stack allocation for a config "
+				  "string failed");
+			return 0;
+		}
+		line_append("\"%s\"", dm_escape_double_quotes(buf, v->v.str));
+		break;
+
+	case DM_CFG_FLOAT:
+		line_append("%f", v->v.r);
+		break;
+
+	case DM_CFG_INT:
+		line_append("%" PRId64, v->v.i);
+		break;
+
+	case DM_CFG_EMPTY_ARRAY:
+		line_append("[]");
+		break;
+
+	default:
+		log_error("_write_value: Unknown value type: %d", v->type);
+
+	}
+
+	return 1;
+}
+
+static int _write_config(const struct dm_config_node *n, int only_one,
+			 struct output_line *outline, int level)
+{
+	char space[MAX_INDENT + 1];
+	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
+	int i;
+
+	if (!n)
+		return 1;
+
+	for (i = 0; i < l; i++)
+		space[i] = '\t';
+	space[i] = '\0';
+
+	do {
+		if (!_line_start(outline))
+			return_0;
+		line_append("%s%s", space, n->key);
+		if (!n->v) {
+			/* it's a sub section */
+			line_append(" {");
+			if (!_line_end(outline))
+				return_0;
+			_write_config(n->child, 0, outline, level + 1);
+			if (!_line_start(outline))
+				return_0;
+			line_append("%s}", space);
+		} else {
+			/* it's a value */
+			const struct dm_config_value *v = n->v;
+			line_append("=");
+			if (v->next) {
+				line_append("[");
+				while (v && v->type != DM_CFG_EMPTY_ARRAY) {
+					if (!_write_value(outline, v))
+						return_0;
+					v = v->next;
+					if (v && v->type != DM_CFG_EMPTY_ARRAY)
+						line_append(", ");
+				}
+				line_append("]");
+			} else
+				if (!_write_value(outline, v))
+					return_0;
+		}
+		if (!_line_end(outline))
+			return_0;
+		n = n->sib;
+	} while (n && !only_one);
+	/* FIXME: add error checking */
+	return 1;
+}
+
+int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton)
+{
+	struct output_line outline;
+	outline.fp = NULL;
+	if (!(outline.mem = dm_pool_create("config_line", 1024)))
+		return_0;
+	outline.putline = putline;
+	outline.putline_baton = baton;
+	if (!_write_config(cn, 0, &outline, 0)) {
+		dm_pool_destroy(outline.mem);
+		return_0;
+	}
+	dm_pool_destroy(outline.mem);
+	return 1;
+}
+
+int dm_config_write(struct dm_config_tree *cft, const char *file,
+		    int argc, char **argv)
+{
+	const struct dm_config_node *cn;
+	int r = 1;
+	struct output_line outline;
+	outline.fp = NULL;
+	outline.putline = NULL;
+
+	if (!file)
+		file = "stdout";
+	else if (!(outline.fp = fopen(file, "w"))) {
+		log_sys_error("open", file);
+		return 0;
+	}
+
+	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
+		r = 0;
+		goto_out;
+	}
+
+	log_verbose("Dumping configuration to %s", file);
+	if (!argc) {
+		if (!_write_config(cft->root, 0, &outline, 0)) {
+			log_error("Failure while writing to %s", file);
+			r = 0;
+		}
+	} else while (argc--) {
+		if ((cn = dm_config_find_node(cft->root, *argv))) {
+			if (!_write_config(cn, 1, &outline, 0)) {
+				log_error("Failure while writing to %s", file);
+				r = 0;
+			}
+		} else {
+			log_error("Configuration node %s not found", *argv);
+			r = 0;
+		}
+		argv++;
+	}
+
+	dm_pool_destroy(outline.mem);
+
+out:
+	if (outline.fp && dm_fclose(outline.fp)) {
+		stack;
+		r = 0;
+	}
+
+	return r;
+}
+
+/*
+ * parser
+ */
+static struct dm_config_node *_file(struct parser *p)
+{
+	struct dm_config_node *root = NULL, *n, *l = NULL;
+	while (p->t != TOK_EOF) {
+		if (!(n = _section(p)))
+			return_0;
+
+		if (!root)
+			root = n;
+		else
+			l->sib = n;
+		n->parent = root;
+		l = n;
+	}
+	return root;
+}
+
+static struct dm_config_node *_section(struct parser *p)
+{
+	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
+	struct dm_config_node *root, *n, *l = NULL;
+	if (!(root = _create_node(p->mem)))
+		return_0;
+
+	if (!(root->key = _dup_tok(p)))
+		return_0;
+
+	match(TOK_IDENTIFIER);
+
+	if (p->t == TOK_SECTION_B) {
+		match(TOK_SECTION_B);
+		while (p->t != TOK_SECTION_E) {
+			if (!(n = _section(p)))
+				return_0;
+
+			if (!root->child)
+				root->child = n;
+			else
+				l->sib = n;
+			n->parent = root;
+			l = n;
+		}
+		match(TOK_SECTION_E);
+	} else {
+		match(TOK_EQ);
+		if (!(root->v = _value(p)))
+			return_0;
+	}
+
+	return root;
+}
+
+static struct dm_config_value *_value(struct parser *p)
+{
+	/* '[' TYPE* ']' | TYPE */
+	struct dm_config_value *h = NULL, *l, *ll = NULL;
+	if (p->t == TOK_ARRAY_B) {
+		match(TOK_ARRAY_B);
+		while (p->t != TOK_ARRAY_E) {
+			if (!(l = _type(p)))
+				return_0;
+
+			if (!h)
+				h = l;
+			else
+				ll->next = l;
+			ll = l;
+
+			if (p->t == TOK_COMMA)
+				match(TOK_COMMA);
+		}
+		match(TOK_ARRAY_E);
+		/*
+		 * Special case for an empty array.
+		 */
+		if (!h) {
+			if (!(h = _create_value(p->mem)))
+				return NULL;
+
+			h->type = DM_CFG_EMPTY_ARRAY;
+		}
+
+	} else
+		h = _type(p);
+
+	return h;
+}
+
+static struct dm_config_value *_type(struct parser *p)
+{
+	/* [+-]{0,1}[0-9]+ | [0-9]*\.[0-9]* | ".*" */
+	struct dm_config_value *v = _create_value(p->mem);
+	char *str;
+
+	if (!v)
+		return NULL;
+
+	switch (p->t) {
+	case TOK_INT:
+		v->type = DM_CFG_INT;
+		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
+		match(TOK_INT);
+		break;
+
+	case TOK_FLOAT:
+		v->type = DM_CFG_FLOAT;
+		v->v.r = strtod(p->tb, NULL);	/* FIXME: check error */
+		match(TOK_FLOAT);
+		break;
+
+	case TOK_STRING:
+		v->type = DM_CFG_STRING;
+
+		p->tb++, p->te--;	/* strip "'s */
+		if (!(v->v.str = _dup_tok(p)))
+			return_0;
+		p->te++;
+		match(TOK_STRING);
+		break;
+
+	case TOK_STRING_ESCAPED:
+		v->type = DM_CFG_STRING;
+
+		p->tb++, p->te--;	/* strip "'s */
+		if (!(str = _dup_tok(p)))
+			return_0;
+		dm_unescape_double_quotes(str);
+		v->v.str = str;
+		p->te++;
+		match(TOK_STRING_ESCAPED);
+		break;
+
+	default:
+		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
+			  p->tb - p->fb + 1, p->line);
+		return 0;
+	}
+	return v;
+}
+
+static int _match_aux(struct parser *p, int t)
+{
+	if (p->t != t)
+		return 0;
+
+	_get_token(p, t);
+	return 1;
+}
+
+/*
+ * tokeniser
+ */
+static void _get_token(struct parser *p, int tok_prev)
+{
+	int values_allowed = 0;
+
+	const char *te;
+
+	p->tb = p->te;
+	_eat_space(p);
+	if (p->tb == p->fe || !*p->tb) {
+		p->t = TOK_EOF;
+		return;
+	}
+
+	/* Should next token be interpreted as value instead of identifier? */
+	if (tok_prev == TOK_EQ || tok_prev == TOK_ARRAY_B ||
+	    tok_prev == TOK_COMMA)
+		values_allowed = 1;
+
+	p->t = TOK_INT;		/* fudge so the fall through for
+				   floats works */
+
+	te = p->te;
+	switch (*te) {
+	case SECTION_B_CHAR:
+		p->t = TOK_SECTION_B;
+		te++;
+		break;
+
+	case SECTION_E_CHAR:
+		p->t = TOK_SECTION_E;
+		te++;
+		break;
+
+	case '[':
+		p->t = TOK_ARRAY_B;
+		te++;
+		break;
+
+	case ']':
+		p->t = TOK_ARRAY_E;
+		te++;
+		break;
+
+	case ',':
+		p->t = TOK_COMMA;
+		te++;
+		break;
+
+	case '=':
+		p->t = TOK_EQ;
+		te++;
+		break;
+
+	case '"':
+		p->t = TOK_STRING_ESCAPED;
+		te++;
+		while ((te != p->fe) && (*te) && (*te != '"')) {
+			if ((*te == '\\') && (te + 1 != p->fe) &&
+			    *(te + 1))
+				te++;
+			te++;
+		}
+
+		if ((te != p->fe) && (*te))
+			te++;
+		break;
+
+	case '\'':
+		p->t = TOK_STRING;
+		te++;
+		while ((te != p->fe) && (*te) && (*te != '\''))
+			te++;
+
+		if ((te != p->fe) && (*te))
+			te++;
+		break;
+
+	case '.':
+		p->t = TOK_FLOAT;
+		/* Fall through */
+	case '0':
+	case '1':
+	case '2':
+	case '3':
+	case '4':
+	case '5':
+	case '6':
+	case '7':
+	case '8':
+	case '9':
+	case '+':
+	case '-':
+		if (values_allowed) {
+			while (++te != p->fe) {
+				if (!isdigit((int) *te)) {
+					if (*te == '.') {
+						if (p->t != TOK_FLOAT) {
+							p->t = TOK_FLOAT;
+							continue;
+						}
+					}
+					break;
+				}
+			}
+			break;
+		}
+		/* fall through */
+
+	default:
+		p->t = TOK_IDENTIFIER;
+		while ((te != p->fe) && (*te) && !isspace(*te) &&
+		       (*te != '#') && (*te != '=') &&
+		       (*te != SECTION_B_CHAR) &&
+		       (*te != SECTION_E_CHAR))
+			te++;
+		break;
+	}
+
+	p->te = te;
+}
+
+static void _eat_space(struct parser *p)
+{
+	while (p->tb != p->fe) {
+		if (*p->te == '#')
+			while ((p->te != p->fe) && (*p->te != '\n') && (*p->te))
+				++p->te;
+
+		else if (!isspace(*p->te))
+			break;
+
+		while ((p->te != p->fe) && isspace(*p->te)) {
+			if (*p->te == '\n')
+				++p->line;
+			++p->te;
+		}
+
+		p->tb = p->te;
+	}
+}
+
+/*
+ * memory management
+ */
+static struct dm_config_value *_create_value(struct dm_pool *mem)
+{
+	return dm_pool_zalloc(mem, sizeof(struct dm_config_value));
+}
+
+static struct dm_config_node *_create_node(struct dm_pool *mem)
+{
+	return dm_pool_zalloc(mem, sizeof(struct dm_config_node));
+}
+
+static char *_dup_tok(struct parser *p)
+{
+	size_t len = p->te - p->tb;
+	char *str = dm_pool_alloc(p->mem, len + 1);
+	if (!str) {
+		log_error("Failed to duplicate token.");
+		return 0;
+	}
+	memcpy(str, p->tb, len);
+	str[len] = '\0';
+	return str;
+}
+
+/*
+ * utility functions
+ */
+static const struct dm_config_node *_find_config_node(const void *start,
+						      const char *path)
+{
+	const char *e;
+	const struct dm_config_node *cn = start;
+	const struct dm_config_node *cn_found = NULL;
+
+	while (cn) {
+		/* trim any leading slashes */
+		while (*path && (*path == sep))
+			path++;
+
+		/* find the end of this segment */
+		for (e = path; *e && (*e != sep); e++) ;
+
+		/* hunt for the node */
+		cn_found = NULL;
+		while (cn) {
+			if (_tok_match(cn->key, path, e)) {
+				/* Inefficient */
+				if (!cn_found)
+					cn_found = cn;
+				else
+					log_warn("WARNING: Ignoring duplicate"
+						 " config node: %s ("
+						 "seeking %s)", cn->key, path);
+			}
+
+			cn = cn->sib;
+		}
+
+		if (cn_found && *e)
+			cn = cn_found->child;
+		else
+			break;	/* don't move into the last node */
+
+		path = e;
+	}
+
+	return cn_found;
+}
+
+typedef const struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
+
+static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)
+{
+	const struct dm_config_tree *cft = start;
+	const struct dm_config_node *cn = NULL;
+
+	while (cft) {
+		if ((cn = _find_config_node(cft->root, path)))
+			return cn;
+		cft = cft->cascade;
+	}
+
+	return NULL;
+}
+
+static const char *_find_config_str(const void *start, _node_lookup_fn find,
+				    const char *path, const char *fail)
+{
+	const struct dm_config_node *n = find(start, path);
+
+	/* Empty strings are ignored */
+	if ((n && n->v && n->v->type == DM_CFG_STRING) && (*n->v->v.str)) {
+		log_very_verbose("Setting %s to %s", path, n->v->v.str);
+		return n->v->v.str;
+	}
+
+	if (fail)
+		log_very_verbose("%s not found in config: defaulting to %s",
+				 path, fail);
+	return fail;
+}
+
+const char *dm_config_find_str(const struct dm_config_node *cn,
+			       const char *path, const char *fail)
+{
+	return _find_config_str(cn, _find_config_node, path, fail);
+}
+
+static int64_t _find_config_int64(const void *start, _node_lookup_fn find,
+				  const char *path, int64_t fail)
+{
+	const struct dm_config_node *n = find(start, path);
+
+	if (n && n->v && n->v->type == DM_CFG_INT) {
+		log_very_verbose("Setting %s to %" PRId64, path, n->v->v.i);
+		return n->v->v.i;
+	}
+
+	log_very_verbose("%s not found in config: defaulting to %" PRId64,
+			 path, fail);
+	return fail;
+}
+
+static float _find_config_float(const void *start, _node_lookup_fn find,
+				const char *path, float fail)
+{
+	const struct dm_config_node *n = find(start, path);
+
+	if (n && n->v && n->v->type == DM_CFG_FLOAT) {
+		log_very_verbose("Setting %s to %f", path, n->v->v.r);
+		return n->v->v.r;
+	}
+
+	log_very_verbose("%s not found in config: defaulting to %f",
+			 path, fail);
+
+	return fail;
+
+}
+
+static int _str_in_array(const char *str, const char * const values[])
+{
+	int i;
+
+	for (i = 0; values[i]; i++)
+		if (!strcasecmp(str, values[i]))
+			return 1;
+
+	return 0;
+}
+
+static int _str_to_bool(const char *str, int fail)
+{
+	const char * const _true_values[]  = { "y", "yes", "on", "true", NULL };
+	const char * const _false_values[] = { "n", "no", "off", "false", NULL };
+
+	if (_str_in_array(str, _true_values))
+		return 1;
+
+	if (_str_in_array(str, _false_values))
+		return 0;
+
+	return fail;
+}
+
+static int _find_config_bool(const void *start, _node_lookup_fn find,
+			     const char *path, int fail)
+{
+	const struct dm_config_node *n = find(start, path);
+	const struct dm_config_value *v;
+
+	if (!n)
+		return fail;
+
+	v = n->v;
+
+	switch (v->type) {
+	case DM_CFG_INT:
+		return v->v.i ? 1 : 0;
+
+	case DM_CFG_STRING:
+		return _str_to_bool(v->v.str, fail);
+	}
+
+	return fail;
+}
+
+/***********************************
+ * node-based lookup
+ **/
+
+const struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn,
+						 const char *path)
+{
+	return _find_config_node(cn, path);
+}
+
+int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail)
+{
+	/* FIXME Add log_error message on overflow */
+	return (int) _find_config_int64(cn, _find_config_node, path, (int64_t) fail);
+}
+
+float dm_config_find_float(const struct dm_config_node *cn, const char *path,
+			   float fail)
+{
+	return _find_config_float(cn, _find_config_node, path, fail);
+}
+
+int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail)
+{
+	return _find_config_bool(cn, _find_config_node, path, fail);
+}
+
+/***********************************
+ * tree-based lookup
+ **/
+
+const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft,
+						      const char *path)
+{
+	return _find_first_config_node(cft, path);
+}
+
+const char *dm_config_tree_find_str(const struct dm_config_tree *cft, const char *path,
+				    const char *fail)
+{
+	return _find_config_str(cft, _find_first_config_node, path, fail);
+}
+
+int dm_config_tree_find_int(const struct dm_config_tree *cft, const char *path, int fail)
+{
+	/* FIXME Add log_error message on overflow */
+	return (int) _find_config_int64(cft, _find_first_config_node, path, (int64_t) fail);
+}
+
+int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft, const char *path, int64_t fail)
+{
+	return _find_config_int64(cft, _find_first_config_node, path, fail);
+}
+
+float dm_config_tree_find_float(const struct dm_config_tree *cft, const char *path,
+				float fail)
+{
+	return _find_config_float(cft, _find_first_config_node, path, fail);
+}
+
+int dm_config_tree_find_bool(const struct dm_config_tree *cft, const char *path, int fail)
+{
+	return _find_config_bool(cft, _find_first_config_node, path, fail);
+}
+
+/************************************/
+
+
+int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
+			      uint32_t *result)
+{
+	const struct dm_config_node *n;
+
+	n = dm_config_find_node(cn, path);
+
+	if (!n || !n->v || n->v->type != DM_CFG_INT)
+		return 0;
+
+	*result = n->v->v.i;
+	return 1;
+}
+
+int dm_config_get_uint64(const struct dm_config_node *cn, const char *path,
+			 uint64_t *result)
+{
+	const struct dm_config_node *n;
+
+	n = dm_config_find_node(cn, path);
+
+	if (!n || !n->v || n->v->type != DM_CFG_INT)
+		return 0;
+
+	*result = (uint64_t) n->v->v.i;
+	return 1;
+}
+
+int dm_config_get_str(const struct dm_config_node *cn, const char *path,
+		      const char **result)
+{
+	const struct dm_config_node *n;
+
+	n = dm_config_find_node(cn, path);
+
+	if (!n || !n->v || n->v->type != DM_CFG_STRING)
+		return 0;
+
+	*result = n->v->v.str;
+	return 1;
+}
+
+/*
+ * Convert a token type to the char it represents.
+ */
+static char _token_type_to_char(int type)
+{
+	switch (type) {
+		case TOK_SECTION_B:
+			return SECTION_B_CHAR;
+		case TOK_SECTION_E:
+			return SECTION_E_CHAR;
+		default:
+			return 0;
+	}
+}
+
+/*
+ * Returns:
+ *  # of 'type' tokens in 'str'.
+ */
+static unsigned _count_tokens(const char *str, unsigned len, int type)
+{
+	char c;
+
+	c = _token_type_to_char(type);
+
+	return dm_count_chars(str, len, c);
+}
+
+const char *dm_config_parent_name(const struct dm_config_node *n)
+{
+	return (n->parent ? n->parent->key : "(root)");
+}
+/*
+ * Heuristic function to make a quick guess as to whether a text
+ * region probably contains a valid config "section".  (Useful for
+ * scanning areas of the disk for old metadata.)
+ * Config sections contain various tokens, may contain other sections
+ * and strings, and are delimited by begin (type 'TOK_SECTION_B') and
+ * end (type 'TOK_SECTION_E') tokens.  As a quick heuristic, we just
+ * count the number of begin and end tokens, and see if they are
+ * non-zero and the counts match.
+ * Full validation of the section should be done with another function
+ * (for example, read_config_fd).
+ *
+ * Returns:
+ *  0 - probably is not a valid config section
+ *  1 - probably _is_ a valid config section
+ */
+unsigned dm_config_maybe_section(const char *str, unsigned len)
+{
+	int begin_count;
+	int end_count;
+
+	begin_count = _count_tokens(str, len, TOK_SECTION_B);
+	end_count = _count_tokens(str, len, TOK_SECTION_E);
+
+	if (begin_count && end_count && (begin_count == end_count))
+		return 1;
+	else
+		return 0;
+}
+
+static struct dm_config_value *_clone_config_value(struct dm_pool *mem,
+						   const struct dm_config_value *v)
+{
+	struct dm_config_value *new_cv;
+
+	if (!v)
+		return NULL;
+
+	if (!(new_cv = _create_value(mem))) {
+		log_error("Failed to clone config value.");
+		return NULL;
+	}
+
+	new_cv->type = v->type;
+	if (v->type == DM_CFG_STRING) {
+		if (!(new_cv->v.str = dm_pool_strdup(mem, v->v.str))) {
+			log_error("Failed to clone config string value.");
+			return NULL;
+		}
+	} else
+		new_cv->v = v->v;
+
+	if (v->next && !(new_cv->next = _clone_config_value(mem, v->next)))
+		return_NULL;
+
+	return new_cv;
+}
+
+struct dm_config_node *dm_config_clone_node_with_mem(struct dm_pool *mem, const struct dm_config_node *cn, int siblings)
+{
+	struct dm_config_node *new_cn;
+
+	if (!cn)
+		return NULL;
+
+	if (!(new_cn = _create_node(mem))) {
+		log_error("Failed to clone config node.");
+		return NULL;
+	}
+
+	if ((cn->key && !(new_cn->key = dm_pool_strdup(mem, cn->key)))) {
+		log_error("Failed to clone config node key.");
+		return NULL;
+	}
+
+	if ((cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
+	    (cn->child && !(new_cn->child = dm_config_clone_node_with_mem(mem, cn->child, 1))) ||
+	    (siblings && cn->sib && !(new_cn->sib = dm_config_clone_node_with_mem(mem, cn->sib, siblings))))
+		return_NULL; /* 'new_cn' released with mem pool */
+
+	return new_cn;
+}
+
+struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft, const struct dm_config_node *node, int sib)
+{
+	struct cs *c = (struct cs *) cft;
+	return dm_config_clone_node_with_mem(c->mem, node, sib);
+}
+
+struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const char *key)
+{
+	struct cs *c = (struct cs *) cft;
+	struct dm_config_node *cn;
+
+	if (!(cn = _create_node(c->mem))) {
+		log_error("Failed to create config node.");
+		return NULL;
+	}
+	if (!(cn->key = dm_pool_strdup(c->mem, key))) {
+		log_error("Failed to create config node's key.");
+		return NULL;
+	}
+	if (!(cn->v = _create_value(c->mem))) {
+		log_error("Failed to create config node's value.");
+		return NULL;
+	}
+	cn->parent = NULL;
+	cn->v->type = DM_CFG_INT;
+	cn->v->v.i = 0;
+	cn->v->next = NULL;
+	return cn;
+}
+
+struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return _create_value(c->mem);
+}
+
+struct dm_pool *dm_config_memory(struct dm_config_tree *cft)
+{
+	struct cs *c = (struct cs *) cft;
+	return c->mem;
+}
--- LVM2/libdm/Makefile.in	2010/08/03 13:00:46	1.57
+++ LVM2/libdm/Makefile.in	2011/08/30 14:55:15	1.58
@@ -25,6 +25,7 @@
 	libdm-deptree.c \
 	libdm-string.c \
 	libdm-report.c \
+	libdm-config.c \
 	mm/dbg_malloc.c \
 	mm/pool.c \
 	regex/matcher.c \
--- LVM2/libdm/libdevmapper.h	2011/08/19 16:26:03	1.144
+++ LVM2/libdm/libdevmapper.h	2011/08/30 14:55:15	1.145
@@ -19,6 +19,7 @@
 #include <inttypes.h>
 #include <stdarg.h>
 #include <sys/types.h>
+#include <sys/stat.h>
 
 #ifdef linux
 #  include <linux/types.h>
@@ -1014,6 +1015,46 @@
  */
 const char *dm_basename(const char *path);
 
+/*
+ * Count occurences of 'c' in 'str' of length 'size'.
+ *
+ * Returns:
+ *   Number of occurrences of 'c'
+ */
+unsigned dm_count_chars(const char *str, size_t len, const int c);
+
+/*
+ * Length of string after escaping double quotes and backslashes.
+ */
+size_t dm_escaped_len(const char *str);
+
+/*
+ * <vg>-<lv>-<layer> or if !layer just <vg>-<lv>.
+ */
+char *dm_build_dm_name(struct dm_pool *mem, const char *vgname,
+		       const char *lvname, const char *layer);
+char *dm_build_dm_uuid(struct dm_pool *mem, const char *prefix, const char *lvid, const char *layer);
+
+/*
+ * Copies a string, quoting double quotes with backslashes.
+ */
+char *dm_escape_double_quotes(char *out, const char *src);
+
+/*
+ * Undo quoting in situ.
+ */
+void dm_unescape_double_quotes(char *src);
+
+/*
+ * Unescape colons and "at" signs in situ and save the substrings
+ * starting at the position of the first unescaped colon and the
+ * first unescaped "at" sign. This is normally used to unescape
+ * device names used as PVs.
+ */
+void dm_unescape_colons_and_at_signs(char *src,
+				     char **substr_first_unquoted_colon,
+				     char **substr_first_unquoted_at_sign);
+
 /**************************
  * file/stream manipulation
  **************************/
@@ -1181,6 +1222,108 @@
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+
+/*********************************
+ * config file parse/prettyprint
+ *********************************/
+enum {
+	DM_CFG_STRING,
+	DM_CFG_FLOAT,
+	DM_CFG_INT,
+	DM_CFG_EMPTY_ARRAY
+};
+
+struct dm_config_value {
+	int type;
+	union {
+		int64_t i;
+		float r;
+		const char *str;
+	} v;
+	struct dm_config_value *next;	/* for arrays */
+};
+
+struct dm_config_node {
+	const char *key;
+	struct dm_config_node *parent, *sib, *child;
+	struct dm_config_value *v;
+};
+
+struct dm_config_tree {
+	struct dm_config_node *root;
+	struct dm_config_tree *cascade;
+};
+
+struct dm_config_tree *dm_config_create(const char *filename, int keep_open);
+struct dm_config_tree *dm_config_from_string(const char *config_settings);
+int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end);
+
+void *dm_config_get_custom(struct dm_config_tree *cft);
+int dm_config_check_file(struct dm_config_tree *cft, const char **filename, struct stat *info);
+int dm_config_keep_open(struct dm_config_tree *ctf);
+
+void dm_config_set_custom(struct dm_config_tree *cft, void *custom);
+
+void dm_config_destroy(struct dm_config_tree *cft);
+
+int dm_config_write(struct dm_config_tree *cft, const char *file,
+		    int argc, char **argv);
+
+typedef int (*dm_putline_fn)(const char *line, void *baton);
+int dm_config_write_node(const struct dm_config_node *cn, dm_putline_fn putline, void *baton);
+
+time_t dm_config_timestamp(struct dm_config_tree *cft);
+int dm_config_changed(struct dm_config_tree *cft);
+
+const struct dm_config_node *dm_config_find_node(const struct dm_config_node *cn, const char *path);
+const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
+int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
+float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
+
+const struct dm_config_node *dm_config_tree_find_node(
+	const struct dm_config_tree *cft, const char *path);
+const char *dm_config_tree_find_str(const struct dm_config_tree *cft,
+				    const char *path, const char *fail);
+int dm_config_tree_find_int(const struct dm_config_tree *cft,
+			    const char *path, int fail);
+int64_t dm_config_tree_find_int64(const struct dm_config_tree *cft,
+				  const char *path, int64_t fail);
+float dm_config_tree_find_float(const struct dm_config_tree *cft,
+				const char *path, float fail);
+int dm_config_tree_find_bool(const struct dm_config_tree *cft,
+			     const char *path, int fail);
+
+/*
+ * Understands (0, ~0), (y, n), (yes, no), (on,
+ * off), (true, false).
+ */
+int dm_config_find_bool(const struct dm_config_node *cn, const char *path, int fail);
+
+int dm_config_get_uint32(const struct dm_config_node *cn, const char *path,
+			 uint32_t *result);
+
+int dm_config_get_uint64(const struct dm_config_node *cn, const char *path,
+			 uint64_t *result);
+
+int dm_config_get_str(const struct dm_config_node *cn, const char *path,
+		      const char **result);
+
+unsigned dm_config_maybe_section(const char *str, unsigned len);
+
+const char *dm_config_parent_name(const struct dm_config_node *n);
+
+struct dm_config_node *dm_config_clone_node_with_mem(struct dm_pool *mem,
+						     const struct dm_config_node *node,
+						     int siblings);
+struct dm_config_node *dm_config_create_node(struct dm_config_tree *cft, const char *key);
+struct dm_config_value *dm_config_create_value(struct dm_config_tree *cft);
+struct dm_config_node *dm_config_clone_node(struct dm_config_tree *cft,
+					    const struct dm_config_node *cn,
+					    int siblings);
+
+struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
+
+
 /* Cookie prefixes.
  * The cookie value consists of a prefix (16 bits) and a base (16 bits).
  * We can use the prefix to store the flags. These flags are sent to
--- LVM2/libdm/libdm-string.c	2010/11/23 15:00:52	1.14
+++ LVM2/libdm/libdm-string.c	2011/08/30 14:55:16	1.15
@@ -161,3 +161,225 @@
 	dm_free(buf);
 	return n + 1;
 }
+
+/*
+ * Count occurences of 'c' in 'str' until we reach a null char.
+ *
+ * Returns:
+ *  len - incremented for each char we encounter.
+ *  count - number of occurrences of 'c' and 'c2'.
+ */
+static void _count_chars(const char *str, size_t *len, int *count,
+			 const int c1, const int c2)
+{
+	const char *ptr;
+
+	for (ptr = str; *ptr; ptr++, (*len)++)
+		if (*ptr == c1 || *ptr == c2)
+			(*count)++;
+}
+
+unsigned dm_count_chars(const char *str, size_t len, const int c)
+{
+	size_t i;
+	unsigned count = 0;
+
+	for (i = 0; i < len; i++)
+		if (str[i] == c)
+			count++;
+
+	return count;
+}
+
+size_t dm_escaped_len(const char *str)
+{
+	size_t len = 1;
+	int count = 0;
+
+	_count_chars(str, &len, &count, '\"', '\\');
+
+	return count + len;
+}
+
+/*
+ * Copies a string, quoting orig_char with quote_char.
+ * Optionally also quote quote_char.
+ */
+static void _quote_characters(char **out, const char *src,
+			      const int orig_char, const int quote_char,
+			      int quote_quote_char)
+{
+	while (*src) {
+		if (*src == orig_char ||
+		    (*src == quote_char && quote_quote_char))
+			*(*out)++ = quote_char;
+
+		*(*out)++ = *src++;
+	}
+}
+
+static void _unquote_one_character(char *src, const char orig_char,
+				   const char quote_char)
+{
+	char *out;
+	char s, n;
+
+	/* Optimise for the common case where no changes are needed. */
+	while ((s = *src++)) {
+		if (s == quote_char &&
+		    ((n = *src) == orig_char || n == quote_char)) {
+			out = src++;
+			*(out - 1) = n;
+
+			while ((s = *src++)) {
+				if (s == quote_char &&
+				    ((n = *src) == orig_char || n == quote_char)) {
+					s = n;
+					src++;
+				}
+				*out = s;
+				out++;
+			}
+
+			*out = '\0';
+			return;
+		}
+	}
+}
+
+/*
+ * Unquote each character given in orig_char array and unquote quote_char
+ * as well. Also save the first occurrence of each character from orig_char
+ * that was found unquoted in arr_substr_first_unquoted array. This way we can
+ * process several characters in one go.
+ */
+static void _unquote_characters(char *src, const char *orig_chars,
+				size_t num_orig_chars,
+				const char quote_char,
+				char *arr_substr_first_unquoted[])
+{
+	char *out = src;
+	char c, s, n;
+	unsigned i;
+
+	while ((s = *src++)) {
+		for (i = 0; i < num_orig_chars; i++) {
+			c = orig_chars[i];
+			if (s == quote_char &&
+			    ((n = *src) == c || n == quote_char)) {
+				s = n;
+				src++;
+				break;
+			}
+			if (arr_substr_first_unquoted && (s == c) &&
+			    !arr_substr_first_unquoted[i])
+				arr_substr_first_unquoted[i] = out;
+		};
+		*out++ = s;
+	}
+
+	*out = '\0';
+}
+
+/*
+ * Copies a string, quoting hyphens with hyphens.
+ */
+static void _quote_hyphens(char **out, const char *src)
+{
+	_quote_characters(out, src, '-', '-', 0);
+}
+
+char *dm_build_dm_name(struct dm_pool *mem, const char *vgname,
+		       const char *lvname, const char *layer)
+{
+	size_t len = 1;
+	int hyphens = 1;
+	char *r, *out;
+
+	_count_chars(vgname, &len, &hyphens, '-', 0);
+	_count_chars(lvname, &len, &hyphens, '-', 0);
+
+	if (layer && *layer) {
+		_count_chars(layer, &len, &hyphens, '-', 0);
+		hyphens++;
+	}
+
+	len += hyphens;
+
+	if (!(r = dm_pool_alloc(mem, len))) {
+		log_error("build_dm_name: Allocation failed for %" PRIsize_t
+			  " for %s %s %s.", len, vgname, lvname, layer);
+		return NULL;
+	}
+
+	out = r;
+	_quote_hyphens(&out, vgname);
+	*out++ = '-';
+	_quote_hyphens(&out, lvname);
+
+	if (layer && *layer) {
+		/* No hyphen if the layer begins with _ e.g. _mlog */
+		if (*layer != '_')
+			*out++ = '-';
+		_quote_hyphens(&out, layer);
+	}
+	*out = '\0';
+
+	return r;
+}
+
+char *dm_build_dm_uuid(struct dm_pool *mem, const char *prefix, const char *lvid, const char *layer)
+{
+	char *dmuuid;
+	size_t len;
+
+	if (!layer)
+		layer = "";
+
+	len = strlen(prefix) + strlen(lvid) + strlen(layer) + 1;
+
+	if (!(dmuuid = dm_pool_alloc(mem, len))) {
+		log_error("build_dm_name: Allocation failed for %" PRIsize_t
+			  " %s %s.", len, lvid, layer);
+		return NULL;
+	}
+
+	sprintf(dmuuid, "%s%s%s%s", prefix, lvid, (*layer) ? "-" : "", layer);
+
+	return dmuuid;
+}
+
+/*
+ * Copies a string, quoting double quotes with backslashes.
+ */
+char *dm_escape_double_quotes(char *out, const char *src)
+{
+	char *buf = out;
+
+	_quote_characters(&buf, src, '\"', '\\', 1);
+	*buf = '\0';
+
+	return out;
+}
+
+void dm_unescape_double_quotes(char *src)
+{
+	_unquote_one_character(src, '\"', '\\');
+}
+
+void dm_unescape_colons_and_at_signs(char *src,
+				     char **substr_first_unquoted_colon,
+				     char **substr_first_unquoted_at_sign)
+{
+	const char *orig_chars = ":@";
+	char *arr_substr_first_unquoted[] = {NULL, NULL, NULL};
+
+	_unquote_characters(src, orig_chars, 2, '\\', arr_substr_first_unquoted);
+
+	if (substr_first_unquoted_colon)
+		*substr_first_unquoted_colon = arr_substr_first_unquoted[0];
+
+	if (substr_first_unquoted_at_sign)
+		*substr_first_unquoted_at_sign = arr_substr_first_unquoted[1];
+}
+
--- LVM2/lib/activate/activate.c	2011/08/11 18:24:41	1.211
+++ LVM2/lib/activate/activate.c	2011/08/30 14:55:16	1.212
@@ -273,8 +273,8 @@
 static int _passes_activation_filter(struct cmd_context *cmd,
 				     struct logical_volume *lv)
 {
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	const char *str;
 	char path[PATH_MAX];
 
@@ -304,7 +304,7 @@
 			    lv->vg->name, lv->name);
 
 	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Ignoring invalid string in config file "
 				  "activation/volume_list");
 			continue;
--- LVM2/lib/activate/dev_manager.c	2011/08/18 19:38:26	1.230
+++ LVM2/lib/activate/dev_manager.c	2011/08/30 14:55:16	1.231
@@ -269,7 +269,7 @@
 	char *dlid, *name;
 	int r;
 
-	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, layer))) {
+	if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, layer))) {
 		log_error("name build failed for %s", lv->name);
 		return 0;
 	}
@@ -723,7 +723,7 @@
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
@@ -757,7 +757,7 @@
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
@@ -800,7 +800,7 @@
 	/* Rename? */
 		if ((suffix = strrchr(dl->dlid + sizeof(UUID_PREFIX) - 1, '-')))
 			suffix++;
-		new_name = build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
+		new_name = dm_build_dm_name(dm->mem, dm->vg_name, dl->lv->name,
 					suffix);
 
 static int _belong_to_vg(const char *vgname, const char *name)
@@ -843,7 +843,7 @@
 {
 	char *name;
 
-	if (!(name = build_dm_name(lv->vg->cmd->mem, lv->vg->name,
+	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name,
 				   lv->name, NULL)))
 		return_0;
 
@@ -861,7 +861,7 @@
 	char *name;
 	int r = 0;
 
-	if (!(name = build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
 		return_0;
 
 	if ((r = _info_run(name, NULL, &dminfo, NULL, 1, 0, 0, 0, 0))) {
@@ -933,7 +933,7 @@
 	char *dlid, *name;
 	struct dm_info info, info2;
 
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
@@ -1163,7 +1163,7 @@
 	if (!(id = build_dm_uuid(dm->mem, seg->lv->lvid.s, errid)))
 		return_NULL;
 
-	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
+	if (!(name = dm_build_dm_name(dm->mem, seg->lv->vg->name,
 				   seg->lv->name, errid)))
 		return_NULL;
 	if (!(node = dm_tree_add_new_dev(dtree, name, id, 0, 0, 0, 0, 0)))
@@ -1558,7 +1558,7 @@
 		}
 	}
 
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
--- LVM2/lib/cache/lvmcache.c	2011/08/11 17:46:13	1.116
+++ LVM2/lib/cache/lvmcache.c	2011/08/30 14:55:16	1.117
@@ -677,7 +677,7 @@
 	/* Build config tree from vgmetadata, if not yet cached */
 	if (!vginfo->cft &&
 	    !(vginfo->cft =
-	      create_config_tree_from_string(vginfo->vgmetadata)))
+	      dm_config_from_string(vginfo->vgmetadata)))
 		goto_bad;
 
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
--- LVM2/lib/cache/lvmcache.h	2011/08/11 17:24:24	1.40
+++ LVM2/lib/cache/lvmcache.h	2011/08/30 14:55:16	1.41
@@ -33,7 +33,7 @@
 struct cmd_context;
 struct format_type;
 struct volume_group;
-struct config_tree;
+struct dm_config_tree;
 
 /* One per VG */
 struct lvmcache_vginfo {
@@ -48,8 +48,8 @@
 	char *creation_host;
 	size_t vgmetadata_size;
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
-	struct config_tree *cft; /* Config tree created from vgmetadata */
-				/* Lifetime is directly tied to vgmetadata */
+	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
+				    /* Lifetime is directly tied to vgmetadata */
 	struct volume_group *cached_vg;
 	unsigned holders;
 	unsigned vg_use_count;	/* Counter of vg reusage */
--- LVM2/lib/commands/toolcontext.c	2011/08/25 10:00:09	1.130
+++ LVM2/lib/commands/toolcontext.c	2011/08/30 14:55:16	1.131
@@ -222,8 +222,8 @@
 	mode_t old_umask;
 	const char *read_ahead;
 	struct stat st;
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	int64_t pv_min_kb;
 
 	/* umask */
@@ -358,7 +358,7 @@
 
 	if ((cn = find_config_tree_node(cmd, "activation/mlock_filter")))
 		for (cv = cn->v; cv; cv = cv->next) 
-			if ((cv->type != CFG_STRING) || !cv->v.str[0]) 
+			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
 
 	cmd->metadata_read_only = find_config_tree_int(cmd, "global/metadata_read_only",
@@ -392,11 +392,11 @@
 	return 1;
 }
 
-static int _check_host_filters(struct cmd_context *cmd, const struct config_node *hn,
+static int _check_host_filters(struct cmd_context *cmd, const struct dm_config_node *hn,
 			       int *passes)
 {
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 
 	*passes = 1;
 
@@ -405,10 +405,10 @@
 			continue;
 		if (!strcmp(cn->key, "host_list")) {
 			*passes = 0;
-			if (cn->v->type == CFG_EMPTY_ARRAY)
+			if (cn->v->type == DM_CFG_EMPTY_ARRAY)
 				continue;
 			for (cv = cn->v; cv; cv = cv->next) {
-				if (cv->type != CFG_STRING) {
+				if (cv->type != DM_CFG_STRING) {
 					log_error("Invalid hostname string "
 						  "for tag %s", cn->key);
 					return 0;
@@ -428,17 +428,17 @@
 	return 1;
 }
 
-static int _init_tags(struct cmd_context *cmd, struct config_tree *cft)
+static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 {
-	const struct config_node *tn, *cn;
+	const struct dm_config_node *tn, *cn;
 	const char *tag;
 	int passes;
 
-	if (!(tn = find_config_node(cft->root, "tags")) || !tn->child)
+	if (!(tn = dm_config_find_node(cft->root, "tags")) || !tn->child)
 		return 1;
 
 	/* NB hosttags 0 when already 1 intentionally does not delete the tag */
-	if (!cmd->hosttags && find_config_int(cft->root, "tags/hosttags",
+	if (!cmd->hosttags && dm_config_find_int(cft->root, "tags/hosttags",
 					      DEFAULT_HOSTTAGS)) {
 		/* FIXME Strip out invalid chars: only A-Za-z0-9_+.- */
 		if (!_set_tag(cmd, cmd->hostname))
@@ -491,7 +491,7 @@
 		return 0;
 	}
 
-	if (!(cfl->cft = create_config_tree(config_file, 0))) {
+	if (!(cfl->cft = dm_config_create(config_file, 0))) {
 		log_error("config_tree allocation failed");
 		return 0;
 	}
@@ -531,7 +531,7 @@
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
 	if (!*cmd->system_dir) {
-		if (!(cmd->cft = create_config_tree(NULL, 0))) {
+		if (!(cmd->cft = dm_config_create(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -564,7 +564,7 @@
 
 	/* Replace temporary duplicate copy of lvm.conf */
 	if (cmd->cft->root) {
-		if (!(cmd->cft = create_config_tree(NULL, 0))) {
+		if (!(cmd->cft = dm_config_create(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -593,7 +593,7 @@
 	struct config_tree_list *cfl;
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
-		if (config_file_changed(cfl->cft))
+		if (dm_config_changed(cfl->cft))
 			return 1;
 	}
 
@@ -620,8 +620,8 @@
 
 static int _init_dev_cache(struct cmd_context *cmd)
 {
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	size_t uninitialized_var(udev_dir_len), len;
 	int device_list_from_udev;
 	const char *uninitialized_var(udev_dir);
@@ -653,7 +653,7 @@
 	}
 
 	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Invalid string in config file: "
 				  "devices/scan");
 			return 0;
@@ -680,7 +680,7 @@
 		return 1;
 
 	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Invalid string in config file: "
 				  "devices/loopfiles");
 			return 0;
@@ -702,7 +702,7 @@
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
 	unsigned nr_filt = 0;
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	struct dev_filter *filters[MAX_FILTERS];
 
 	memset(filters, 0, sizeof(filters));
@@ -823,7 +823,7 @@
 	 */
 	if (load_persistent_cache && !cmd->is_long_lived &&
 	    !stat(dev_cache, &st) &&
-	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
+	    (st.st_ctime > dm_config_timestamp(cmd->cft)) &&
 	    !persistent_filter_load(f4, NULL))
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
@@ -853,7 +853,7 @@
 	struct format_type *fmt;
 
 #ifdef HAVE_LIBDL
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 #endif
 
 	label_init();
@@ -877,12 +877,12 @@
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/format_libraries"))) {
 
-		const struct config_value *cv;
+		const struct dm_config_value *cv;
 		struct format_type *(*init_format_fn) (struct cmd_context *);
 		void *lib;
 
 		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != CFG_STRING) {
+			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
 					  "global/format_libraries");
 				return 0;
@@ -1010,7 +1010,7 @@
 	};
 
 #ifdef HAVE_LIBDL
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 #endif
 
 	for (i = 0; init_segtype_array[i]; i++) {
@@ -1040,12 +1040,12 @@
 	if (!is_static() &&
 	    (cn = find_config_tree_node(cmd, "global/segment_libraries"))) {
 
-		const struct config_value *cv;
+		const struct dm_config_value *cv;
 		int (*init_multiple_segtypes_fn) (struct cmd_context *,
 						  struct segtype_library *);
 
 		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != CFG_STRING) {
+			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
 					  "global/segment_libraries");
 				return 0;
--- LVM2/lib/commands/toolcontext.h	2011/06/17 14:50:54	1.44
+++ LVM2/lib/commands/toolcontext.h	2011/08/30 14:55:16	1.45
@@ -47,11 +47,16 @@
 	char _padding[1];
 };
 
-struct config_tree;
+struct dm_config_tree;
 struct archive_params;
 struct backup_params;
 struct arg_values;
 
+struct config_tree_list {
+	struct dm_list list;
+	struct dm_config_tree *cft;
+};
+
 /* FIXME Split into tool & library contexts */
 /* command-instance-related variables needed by library */
 struct cmd_context {
@@ -87,8 +92,8 @@
 
 	struct dm_list config_files;
 	int config_valid;
-	struct config_tree *cft;
-	struct config_tree *cft_override;
+	struct dm_config_tree *cft;
+	struct dm_config_tree *cft_override;
 	struct config_info default_settings;
 	struct config_info current_settings;
 
--- LVM2/lib/config/config.c	2011/07/21 13:23:49	1.101
+++ LVM2/lib/config/config.c	2011/08/30 14:55:16	1.102
@@ -13,7 +13,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+
 #include "lib.h"
+
 #include "config.h"
 #include "crc.h"
 #include "device.h"
@@ -28,170 +30,20 @@
 #include <fcntl.h>
 #include <ctype.h>
 
-#define SECTION_B_CHAR '{'
-#define SECTION_E_CHAR '}'
-
-enum {
-	TOK_INT,
-	TOK_FLOAT,
-	TOK_STRING,		/* Single quotes */
-	TOK_STRING_ESCAPED,	/* Double quotes */
-	TOK_EQ,
-	TOK_SECTION_B,
-	TOK_SECTION_E,
-	TOK_ARRAY_B,
-	TOK_ARRAY_E,
-	TOK_IDENTIFIER,
-	TOK_COMMA,
-	TOK_EOF
-};
-
-struct parser {
-	const char *fb, *fe;		/* file limits */
-
-	int t;			/* token limits and type */
-	const char *tb, *te;
-
-	int fd;			/* descriptor for file being parsed */
-	int line;		/* line number we are on */
-
-	struct dm_pool *mem;
-};
-
-struct cs {
-	struct config_tree cft;
-	struct dm_pool *mem;
-	time_t timestamp;
-	off_t st_size;
-	char *filename;
-	int exists;
-	int keep_open;
-	struct device *dev;
-};
-
-struct output_line {
-	FILE *fp;
-	struct dm_pool *mem;
-	putline_fn putline;
-	void *putline_baton;
-};
-
-static void _get_token(struct parser *p, int tok_prev);
-static void _eat_space(struct parser *p);
-static struct config_node *_file(struct parser *p);
-static struct config_node *_section(struct parser *p);
-static struct config_value *_value(struct parser *p);
-static struct config_value *_type(struct parser *p);
-static int _match_aux(struct parser *p, int t);
-static struct config_value *_create_value(struct dm_pool *mem);
-static struct config_node *_create_node(struct dm_pool *mem);
-static char *_dup_tok(struct parser *p);
-
-static const int sep = '/';
-
-#define MAX_INDENT 32
-
-#define match(t) do {\
-   if (!_match_aux(p, (t))) {\
-	log_error("Parse error at byte %" PRIptrdiff_t " (line %d): unexpected token", \
-		  p->tb - p->fb + 1, p->line); \
-      return 0;\
-   } \
-} while(0);
-
-static int _tok_match(const char *str, const char *b, const char *e)
-{
-	while (*str && (b != e)) {
-		if (*str++ != *b++)
-			return 0;
-	}
-
-	return !(*str || (b != e));
-}
-
-/*
- * public interface
- */
-struct config_tree *create_config_tree(const char *filename, int keep_open)
-{
-	struct cs *c;
-	struct dm_pool *mem = dm_pool_create("config", 10 * 1024);
-
-	if (!mem) {
-		log_error("Failed to allocate config pool.");
-		return 0;
-	}
-
-	if (!(c = dm_pool_zalloc(mem, sizeof(*c)))) {
-		log_error("Failed to allocate config tree.");
-		dm_pool_destroy(mem);
-		return 0;
-	}
-
-	c->mem = mem;
-	c->cft.root = (struct config_node *) NULL;
-	c->timestamp = 0;
-	c->exists = 0;
-	c->keep_open = keep_open;
-	c->dev = 0;
-	if (filename)
-		c->filename = dm_pool_strdup(c->mem, filename);
-	return &c->cft;
-}
-
-void destroy_config_tree(struct config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-
-	if (c->dev)
-		dev_close(c->dev);
-
-	dm_pool_destroy(c->mem);
-}
-
-static int _parse_config_file(struct parser *p, struct config_tree *cft)
-{
-	p->tb = p->te = p->fb;
-	p->line = 1;
-	_get_token(p, TOK_SECTION_E);
-	if (!(cft->root = _file(p)))
-		return_0;
-
-	return 1;
-}
-
-struct config_tree *create_config_tree_from_string(const char *config_settings)
+void destroy_config_tree(struct dm_config_tree *cft)
 {
-	struct cs *c;
-	struct config_tree *cft;
-	struct parser *p;
-
-	if (!(cft = create_config_tree(NULL, 0)))
-		return_NULL;
-
-	c = (struct cs *) cft;
-	if (!(p = dm_pool_alloc(c->mem, sizeof(*p)))) {
-		log_error("Failed to allocate config tree parser.");
-		destroy_config_tree(cft);
-		return NULL;
-	}
+	struct device *dev = dm_config_get_custom(cft);
 
-	p->mem = c->mem;
-	p->fb = config_settings;
-	p->fe = config_settings + strlen(config_settings);
-
-	if (!_parse_config_file(p, cft)) {
-		destroy_config_tree(cft);
-		return_NULL;
-	}
+	if (dev)
+		dev_close(dev);
 
-	return cft;
+	dm_config_destroy(cft);
 }
 
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
-	if (!(cmd->cft_override = create_config_tree_from_string(config_settings))) {
+	if (!(cmd->cft_override = dm_config_from_string(config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return 1;
 	}
@@ -199,21 +51,16 @@
 	return 0;
 }
 
-int read_config_fd(struct config_tree *cft, struct device *dev,
+int read_config_fd(struct dm_config_tree *cft, struct device *dev,
 		   off_t offset, size_t size, off_t offset2, size_t size2,
 		   checksum_fn_t checksum_fn, uint32_t checksum)
 {
-	struct cs *c = (struct cs *) cft;
-	struct parser *p;
+	const char *fb, *fe;
 	int r = 0;
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
 	char *buf = NULL;
 
-	if (!(p = dm_pool_alloc(c->mem, sizeof(*p))))
-		return_0;
-	p->mem = c->mem;
-
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || size2)
 		use_mmap = 0;
@@ -221,13 +68,13 @@
 	if (use_mmap) {
 		mmap_offset = offset % lvm_getpagesize();
 		/* memory map the file */
-		p->fb = mmap((caddr_t) 0, size + mmap_offset, PROT_READ,
-			     MAP_PRIVATE, dev_fd(dev), offset - mmap_offset);
-		if (p->fb == (caddr_t) (-1)) {
+		fb = mmap((caddr_t) 0, size + mmap_offset, PROT_READ,
+			  MAP_PRIVATE, dev_fd(dev), offset - mmap_offset);
+		if (fb == (caddr_t) (-1)) {
 			log_sys_error("mmap", dev_name(dev));
 			goto out;
 		}
-		p->fb = p->fb + mmap_offset;
+		fb = fb + mmap_offset;
 	} else {
 		if (!(buf = dm_malloc(size + size2)))
 			return_0;
@@ -235,19 +82,18 @@
 				       (uint64_t) offset2, size2, buf)) {
 			goto out;
 		}
-		p->fb = buf;
+		fb = buf;
 	}
 
 	if (checksum_fn && checksum !=
-	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)p->fb, size),
-			 (const uint8_t *)(p->fb + size), size2))) {
+	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
+			 (const uint8_t *)(fb + size), size2))) {
 		log_error("%s: Checksum error", dev_name(dev));
 		goto out;
 	}
 
-	p->fe = p->fb + size + size2;
-
-	if (!_parse_config_file(p, cft))
+	fe = fb + size + size2;
+	if (!dm_config_parse(cft, fb, fe))
 		goto_out;
 
 	r = 1;
@@ -257,7 +103,7 @@
 		dm_free(buf);
 	else {
 		/* unmap the file */
-		if (munmap((char *) (p->fb - mmap_offset), size + mmap_offset)) {
+		if (munmap((char *) (fb - mmap_offset), size + mmap_offset)) {
 			log_sys_error("munmap", dev_name(dev));
 			r = 0;
 		}
@@ -266,906 +112,85 @@
 	return r;
 }
 
-int read_config_file(struct config_tree *cft)
+int read_config_file(struct dm_config_tree *cft)
 {
-	struct cs *c = (struct cs *) cft;
+	const char *filename;
+	struct device *dev = dm_config_get_custom(cft);
 	struct stat info;
-	int r = 1;
-
-	if (stat(c->filename, &info)) {
-		log_sys_error("stat", c->filename);
-		c->exists = 0;
-		return 0;
-	}
+	int r;
 
-	if (!S_ISREG(info.st_mode)) {
-		log_error("%s is not a regular file", c->filename);
-		c->exists = 0;
+	if (!dm_config_check_file(cft, &filename, &info))
 		return 0;
-	}
-
-	c->exists = 1;
-
-	if (info.st_size == 0) {
-		log_verbose("%s is empty", c->filename);
-		return 1;
-	}
 
-	if (!c->dev) {
-		if (!(c->dev = dev_create_file(c->filename, NULL, NULL, 1)))
+	if (!dev) {
+		if (!(dev = dev_create_file(filename, NULL, NULL, 1)))
 			return_0;
 
-		if (!dev_open_readonly_buffered(c->dev)) {
-			c->dev = 0;
+		if (!dev_open_readonly_buffered(dev))
 			return_0;
-		}
 	}
 
-	r = read_config_fd(cft, c->dev, 0, (size_t) info.st_size, 0, 0,
+	dm_config_set_custom(cft, dev);
+	r = read_config_fd(cft, dev, 0, (size_t) info.st_size, 0, 0,
 			   (checksum_fn_t) NULL, 0);
 
-	if (!c->keep_open) {
-		dev_close(c->dev);
-		c->dev = 0;
+	if (!dm_config_keep_open(cft)) {
+		dev_close(dev);
+		dm_config_set_custom(cft, NULL);
 	}
 
-	c->timestamp = info.st_ctime;
-	c->st_size = info.st_size;
-
 	return r;
 }
 
-time_t config_file_timestamp(struct config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-
-	return c->timestamp;
-}
-
-/*
- * Return 1 if config files ought to be reloaded
- */
-int config_file_changed(struct config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-	struct stat info;
-
-	if (!c->filename)
-		return 0;
-
-	if (stat(c->filename, &info) == -1) {
-		/* Ignore a deleted config file: still use original data */
-		if (errno == ENOENT) {
-			if (!c->exists)
-				return 0;
-			log_very_verbose("Config file %s has disappeared!",
-					 c->filename);
-			goto reload;
-		}
-		log_sys_error("stat", c->filename);
-		log_error("Failed to reload configuration files");
-		return 0;
-	}
-
-	if (!S_ISREG(info.st_mode)) {
-		log_error("Configuration file %s is not a regular file",
-			  c->filename);
-		goto reload;
-	}
-
-	/* Unchanged? */
-	if (c->timestamp == info.st_ctime && c->st_size == info.st_size)
-		return 0;
-
-      reload:
-	log_verbose("Detected config file change to %s", c->filename);
-	return 1;
-}
-
-static int _line_start(struct output_line *outline)
-{
-	if (!dm_pool_begin_object(outline->mem, 128)) {
-		log_error("dm_pool_begin_object failed for config line");
-		return 0;
-	}
-
-	return 1;
-}
-
-static int _line_append(struct output_line *outline, const char *fmt, ...)
-  __attribute__ ((format(printf, 2, 3)));
-static int _line_append(struct output_line *outline, const char *fmt, ...)
-{
-	char buf[4096];
-	va_list ap;
-	int n;
-
-	va_start(ap, fmt);
-	n = vsnprintf(&buf[0], sizeof buf - 1, fmt, ap);
-	va_end(ap);
-
-	if (n < 0 || n > (int) sizeof buf - 1) {
-		log_error("vsnprintf failed for config line");
-		return 0;
-	}
-
-	if (!dm_pool_grow_object(outline->mem, &buf[0], strlen(buf))) {
-		log_error("dm_pool_grow_object failed for config line");
-		return 0;
-	}
-
-	return 1;
-}
-
-#define line_append(args...) do {if (!_line_append(outline, args)) {return_0;}} while (0)
-
-static int _line_end(struct output_line *outline)
-{
-	const char *line;
-
-	if (!dm_pool_grow_object(outline->mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed for config line");
-		return 0;
-	}
-
-	line = dm_pool_end_object(outline->mem);
-	if (outline->putline)
-		outline->putline(line, outline->putline_baton);
-	else {
-		if (!outline->fp)
-			log_print("%s", line);
-		else
-			fprintf(outline->fp, "%s\n", line);
-	}
-
-	return 1;
-}
-
-static int _write_value(struct output_line *outline, const struct config_value *v)
-{
-	char *buf;
-
-	switch (v->type) {
-	case CFG_STRING:
-		if (!(buf = alloca(escaped_len(v->v.str)))) {
-			log_error("temporary stack allocation for a config "
-				  "string failed");
-			return 0;
-		}
-		line_append("\"%s\"", escape_double_quotes(buf, v->v.str));
-		break;
-
-	case CFG_FLOAT:
-		line_append("%f", v->v.r);
-		break;
-
-	case CFG_INT:
-		line_append("%" PRId64, v->v.i);
-		break;
-
-	case CFG_EMPTY_ARRAY:
-		line_append("[]");
-		break;
-
-	default:
-		log_error("_write_value: Unknown value type: %d", v->type);
-
-	}
-
-	return 1;
-}
-
-static int _write_config(const struct config_node *n, int only_one,
-			 struct output_line *outline, int level)
-{
-	char space[MAX_INDENT + 1];
-	int l = (level < MAX_INDENT) ? level : MAX_INDENT;
-	int i;
-
-	if (!n)
-		return 1;
-
-	for (i = 0; i < l; i++)
-		space[i] = '\t';
-	space[i] = '\0';
-
-	do {
-		if (!_line_start(outline))
-			return_0;
-		line_append("%s%s", space, n->key);
-		if (!n->v) {
-			/* it's a sub section */
-			line_append(" {");
-			if (!_line_end(outline))
-				return_0;
-			_write_config(n->child, 0, outline, level + 1);
-			if (!_line_start(outline))
-				return_0;
-			line_append("%s}", space);
-		} else {
-			/* it's a value */
-			const struct config_value *v = n->v;
-			line_append("=");
-			if (v->next) {
-				line_append("[");
-				while (v && v->type != CFG_EMPTY_ARRAY) {
-					if (!_write_value(outline, v))
-						return_0;
-					v = v->next;
-					if (v && v->type != CFG_EMPTY_ARRAY)
-						line_append(", ");
-				}
-				line_append("]");
-			} else
-				if (!_write_value(outline, v))
-					return_0;
-		}
-		if (!_line_end(outline))
-			return_0;
-		n = n->sib;
-	} while (n && !only_one);
-	/* FIXME: add error checking */
-	return 1;
-}
-
-int write_config_node(const struct config_node *cn, putline_fn putline, void *baton)
-{
-	struct output_line outline;
-	outline.fp = NULL;
-	if (!(outline.mem = dm_pool_create("config_line", 1024)))
-		return_0;
-	outline.putline = putline;
-	outline.putline_baton = baton;
-	if (!_write_config(cn, 0, &outline, 0)) {
-		dm_pool_destroy(outline.mem);
-		return_0;
-	}
-	dm_pool_destroy(outline.mem);
-	return 1;
-}
-
-int write_config_file(struct config_tree *cft, const char *file,
-		      int argc, char **argv)
+static struct dm_config_tree *_setup_context_tree(struct cmd_context *cmd)
 {
-	const struct config_node *cn;
-	int r = 1;
-	struct output_line outline;
-	outline.fp = NULL;
-	outline.putline = NULL;
-
-	if (!file)
-		file = "stdout";
-	else if (!(outline.fp = fopen(file, "w"))) {
-		log_sys_error("open", file);
-		return 0;
-	}
-
-	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
-		r = 0;
-		goto_out;
-	}
-
-	log_verbose("Dumping configuration to %s", file);
-	if (!argc) {
-		if (!_write_config(cft->root, 0, &outline, 0)) {
-			log_error("Failure while writing to %s", file);
-			r = 0;
-		}
-	} else while (argc--) {
-		if ((cn = find_config_node(cft->root, *argv))) {
-			if (!_write_config(cn, 1, &outline, 0)) {
-				log_error("Failure while writing to %s", file);
-				r = 0;
-			}
-		} else {
-			log_error("Configuration node %s not found", *argv);
-			r = 0;
-		}
-		argv++;
-	}
+	struct dm_config_tree *r = cmd->cft_override;
 
-	dm_pool_destroy(outline.mem);
-
-out:
-	if (outline.fp && lvm_fclose(outline.fp, file)) {
-		stack;
-		r = 0;
-	}
+	if (r)
+		r->cascade = cmd->cft;
+	else
+		r = cmd->cft;
 
 	return r;
 }
 
-/*
- * parser
- */
-static struct config_node *_file(struct parser *p)
-{
-	struct config_node *root = NULL, *n, *l = NULL;
-	while (p->t != TOK_EOF) {
-		if (!(n = _section(p)))
-			return_0;
-
-		if (!root)
-			root = n;
-		else
-			l->sib = n;
-		n->parent = root;
-		l = n;
-	}
-	return root;
-}
-
-static struct config_node *_section(struct parser *p)
-{
-	/* IDENTIFIER SECTION_B_CHAR VALUE* SECTION_E_CHAR */
-	struct config_node *root, *n, *l = NULL;
-	if (!(root = _create_node(p->mem)))
-		return_0;
-
-	if (!(root->key = _dup_tok(p)))
-		return_0;
-
-	match(TOK_IDENTIFIER);
-
-	if (p->t == TOK_SECTION_B) {
-		match(TOK_SECTION_B);
-		while (p->t != TOK_SECTION_E) {
-			if (!(n = _section(p)))
-				return_0;
-
-			if (!root->child)
-				root->child = n;
-			else
-				l->sib = n;
-			n->parent = root;
-			l = n;
-		}
-		match(TOK_SECTION_E);
-	} else {
-		match(TOK_EQ);
-		if (!(root->v = _value(p)))
-			return_0;
-	}
-
-	return root;
-}
-
-static struct config_value *_value(struct parser *p)
-{
-	/* '[' TYPE* ']' | TYPE */
-	struct config_value *h = NULL, *l, *ll = NULL;
-	if (p->t == TOK_ARRAY_B) {
-		match(TOK_ARRAY_B);
-		while (p->t != TOK_ARRAY_E) {
-			if (!(l = _type(p)))
-				return_0;
-
-			if (!h)
-				h = l;
-			else
-				ll->next = l;
-			ll = l;
-
-			if (p->t == TOK_COMMA)
-				match(TOK_COMMA);
-		}
-		match(TOK_ARRAY_E);
-		/*
-		 * Special case for an empty array.
-		 */
-		if (!h) {
-			if (!(h = _create_value(p->mem)))
-				return NULL;
-
-			h->type = CFG_EMPTY_ARRAY;
-		}
-
-	} else
-		h = _type(p);
-
-	return h;
-}
-
-static struct config_value *_type(struct parser *p)
-{
-	/* [+-]{0,1}[0-9]+ | [0-9]*\.[0-9]* | ".*" */
-	struct config_value *v = _create_value(p->mem);
-	char *str;
-
-	if (!v)
-		return NULL;
-
-	switch (p->t) {
-	case TOK_INT:
-		v->type = CFG_INT;
-		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
-		match(TOK_INT);
-		break;
-
-	case TOK_FLOAT:
-		v->type = CFG_FLOAT;
-		v->v.r = strtod(p->tb, NULL);	/* FIXME: check error */
-		match(TOK_FLOAT);
-		break;
-
-	case TOK_STRING:
-		v->type = CFG_STRING;
-
-		p->tb++, p->te--;	/* strip "'s */
-		if (!(v->v.str = _dup_tok(p)))
-			return_0;
-		p->te++;
-		match(TOK_STRING);
-		break;
-
-	case TOK_STRING_ESCAPED:
-		v->type = CFG_STRING;
-
-		p->tb++, p->te--;	/* strip "'s */
-		if (!(str = _dup_tok(p)))
-			return_0;
-		unescape_double_quotes(str);
-		v->v.str = str;
-		p->te++;
-		match(TOK_STRING_ESCAPED);
-		break;
-
-	default:
-		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): expected a value",
-			  p->tb - p->fb + 1, p->line);
-		return 0;
-	}
-	return v;
-}
-
-static int _match_aux(struct parser *p, int t)
-{
-	if (p->t != t)
-		return 0;
-
-	_get_token(p, t);
-	return 1;
-}
-
-/*
- * tokeniser
- */
-static void _get_token(struct parser *p, int tok_prev)
-{
-	int values_allowed = 0;
-
-	const char *te;
-
-	p->tb = p->te;
-	_eat_space(p);
-	if (p->tb == p->fe || !*p->tb) {
-		p->t = TOK_EOF;
-		return;
-	}
-
-	/* Should next token be interpreted as value instead of identifier? */
-	if (tok_prev == TOK_EQ || tok_prev == TOK_ARRAY_B ||
-	    tok_prev == TOK_COMMA)
-		values_allowed = 1;
-
-	p->t = TOK_INT;		/* fudge so the fall through for
-				   floats works */
-
-	te = p->te;
-	switch (*te) {
-	case SECTION_B_CHAR:
-		p->t = TOK_SECTION_B;
-		te++;
-		break;
-
-	case SECTION_E_CHAR:
-		p->t = TOK_SECTION_E;
-		te++;
-		break;
-
-	case '[':
-		p->t = TOK_ARRAY_B;
-		te++;
-		break;
-
-	case ']':
-		p->t = TOK_ARRAY_E;
-		te++;
-		break;
-
-	case ',':
-		p->t = TOK_COMMA;
-		te++;
-		break;
-
-	case '=':
-		p->t = TOK_EQ;
-		te++;
-		break;
-
-	case '"':
-		p->t = TOK_STRING_ESCAPED;
-		te++;
-		while ((te != p->fe) && (*te) && (*te != '"')) {
-			if ((*te == '\\') && (te + 1 != p->fe) &&
-			    *(te + 1))
-				te++;
-			te++;
-		}
-
-		if ((te != p->fe) && (*te))
-			te++;
-		break;
-
-	case '\'':
-		p->t = TOK_STRING;
-		te++;
-		while ((te != p->fe) && (*te) && (*te != '\''))
-			te++;
-
-		if ((te != p->fe) && (*te))
-			te++;
-		break;
-
-	case '.':
-		p->t = TOK_FLOAT;
-		/* Fall through */
-	case '0':
-	case '1':
-	case '2':
-	case '3':
-	case '4':
-	case '5':
-	case '6':
-	case '7':
-	case '8':
-	case '9':
-	case '+':
-	case '-':
-		if (values_allowed) {
-			while (++te != p->fe) {
-				if (!isdigit((int) *te)) {
-					if (*te == '.') {
-						if (p->t != TOK_FLOAT) {
-							p->t = TOK_FLOAT;
-							continue;
-						}
-					}
-					break;
-				}
-			}
-			break;
-		}
-		/* fall through */
-
-	default:
-		p->t = TOK_IDENTIFIER;
-		while ((te != p->fe) && (*te) && !isspace(*te) &&
-		       (*te != '#') && (*te != '=') &&
-		       (*te != SECTION_B_CHAR) &&
-		       (*te != SECTION_E_CHAR))
-			te++;
-		break;
-	}
-
-	p->te = te;
-}
-
-static void _eat_space(struct parser *p)
-{
-	while (p->tb != p->fe) {
-		if (*p->te == '#')
-			while ((p->te != p->fe) && (*p->te != '\n') && (*p->te))
-				++p->te;
-
-		else if (!isspace(*p->te))
-			break;
-
-		while ((p->te != p->fe) && isspace(*p->te)) {
-			if (*p->te == '\n')
-				++p->line;
-			++p->te;
-		}
-
-		p->tb = p->te;
-	}
-}
-
-/*
- * memory management
- */
-static struct config_value *_create_value(struct dm_pool *mem)
-{
-	return dm_pool_zalloc(mem, sizeof(struct config_value));
-}
-
-static struct config_node *_create_node(struct dm_pool *mem)
-{
-	return dm_pool_zalloc(mem, sizeof(struct config_node));
-}
-
-static char *_dup_tok(struct parser *p)
-{
-	size_t len = p->te - p->tb;
-	char *str = dm_pool_alloc(p->mem, len + 1);
-	if (!str) {
-		log_error("Failed to duplicate token.");
-		return 0;
-	}
-	memcpy(str, p->tb, len);
-	str[len] = '\0';
-	return str;
-}
-
-/*
- * utility functions
- */
-static const struct config_node *_find_config_node(const struct config_node *cn,
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
 						   const char *path)
 {
-	const char *e;
-	const struct config_node *cn_found = NULL;
-
-	while (cn) {
-		/* trim any leading slashes */
-		while (*path && (*path == sep))
-			path++;
-
-		/* find the end of this segment */
-		for (e = path; *e && (*e != sep); e++) ;
-
-		/* hunt for the node */
-		cn_found = NULL;
-		while (cn) {
-			if (_tok_match(cn->key, path, e)) {
-				/* Inefficient */
-				if (!cn_found)
-					cn_found = cn;
-				else
-					log_warn("WARNING: Ignoring duplicate"
-						 " config node: %s ("
-						 "seeking %s)", cn->key, path);
-			}
-
-			cn = cn->sib;
-		}
-
-		if (cn_found && *e)
-			cn = cn_found->child;
-		else
-			break;	/* don't move into the last node */
-
-		path = e;
-	}
-
-	return cn_found;
-}
-
-static const struct config_node *_find_first_config_node(const struct config_node *cn1,
-							 const struct config_node *cn2,
-							 const char *path)
-{
-	const struct config_node *cn;
-
-	if (cn1 && (cn = _find_config_node(cn1, path)))
-		return cn;
-
-	if (cn2 && (cn = _find_config_node(cn2, path)))
-		return cn;
-
-	return NULL;
-}
-
-const struct config_node *find_config_node(const struct config_node *cn,
-					   const char *path)
-{
-	return _find_config_node(cn, path);
-}
-
-static const char *_find_config_str(const struct config_node *cn1,
-				    const struct config_node *cn2,
-				    const char *path, const char *fail)
-{
-	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-
-	/* Empty strings are ignored */
-	if ((n && n->v && n->v->type == CFG_STRING) && (*n->v->v.str)) {
-		log_very_verbose("Setting %s to %s", path, n->v->v.str);
-		return n->v->v.str;
-	}
-
-	if (fail)
-		log_very_verbose("%s not found in config: defaulting to %s",
-				 path, fail);
-	return fail;
-}
-
-const char *find_config_str(const struct config_node *cn,
-			    const char *path, const char *fail)
-{
-	return _find_config_str(cn, NULL, path, fail);
-}
-
-static int64_t _find_config_int64(const struct config_node *cn1,
-				  const struct config_node *cn2,
-				  const char *path, int64_t fail)
-{
-	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-
-	if (n && n->v && n->v->type == CFG_INT) {
-		log_very_verbose("Setting %s to %" PRId64, path, n->v->v.i);
-		return n->v->v.i;
-	}
-
-	log_very_verbose("%s not found in config: defaulting to %" PRId64,
-			 path, fail);
-	return fail;
-}
-
-int find_config_int(const struct config_node *cn, const char *path, int fail)
-{
-	/* FIXME Add log_error message on overflow */
-	return (int) _find_config_int64(cn, NULL, path, (int64_t) fail);
-}
-
-static float _find_config_float(const struct config_node *cn1,
-				const struct config_node *cn2,
-				const char *path, float fail)
-{
-	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-
-	if (n && n->v && n->v->type == CFG_FLOAT) {
-		log_very_verbose("Setting %s to %f", path, n->v->v.r);
-		return n->v->v.r;
-	}
-
-	log_very_verbose("%s not found in config: defaulting to %f",
-			 path, fail);
-
-	return fail;
-
-}
-
-float find_config_float(const struct config_node *cn, const char *path,
-			float fail)
-{
-	return _find_config_float(cn, NULL, path, fail);
-}
-
-const struct config_node *find_config_tree_node(struct cmd_context *cmd,
-					  const char *path)
-{
-	return _find_first_config_node(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path);
+	return dm_config_tree_find_node(_setup_context_tree(cmd), path);
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail)
 {
-	return _find_config_str(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
+	return dm_config_tree_find_str(_setup_context_tree(cmd), path, fail);
 }
 
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail)
 {
-	/* FIXME Add log_error message on overflow */
-	return (int) _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, (int64_t) fail);
+	return dm_config_tree_find_int(_setup_context_tree(cmd), path, fail);
 }
 
 int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path, int64_t fail)
 {
-	return _find_config_int64(cmd->cft_override ? cmd->cft_override->root : NULL,
-				  cmd->cft->root, path, fail);
+	return dm_config_tree_find_int64(_setup_context_tree(cmd), path, fail);
 }
 
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail)
 {
-	return _find_config_float(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
-}
-
-static int _str_in_array(const char *str, const char * const values[])
-{
-	int i;
-
-	for (i = 0; values[i]; i++)
-		if (!strcasecmp(str, values[i]))
-			return 1;
-
-	return 0;
-}
-
-static int _str_to_bool(const char *str, int fail)
-{
-	const char * const _true_values[]  = { "y", "yes", "on", "true", NULL };
-	const char * const _false_values[] = { "n", "no", "off", "false", NULL };
-
-	if (_str_in_array(str, _true_values))
-		return 1;
-
-	if (_str_in_array(str, _false_values))
-		return 0;
-
-	return fail;
-}
-
-static int _find_config_bool(const struct config_node *cn1,
-			     const struct config_node *cn2,
-			     const char *path, int fail)
-{
-	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
-	const struct config_value *v;
-
-	if (!n)
-		return fail;
-
-	v = n->v;
-
-	switch (v->type) {
-	case CFG_INT:
-		return v->v.i ? 1 : 0;
-
-	case CFG_STRING:
-		return _str_to_bool(v->v.str, fail);
-	}
-
-	return fail;
-}
-
-int find_config_bool(const struct config_node *cn, const char *path, int fail)
-{
-	return _find_config_bool(cn, NULL, path, fail);
+	return dm_config_tree_find_float(_setup_context_tree(cmd), path, fail);
 }
 
 int find_config_tree_bool(struct cmd_context *cmd, const char *path, int fail)
 {
-	return _find_config_bool(cmd->cft_override ? cmd->cft_override->root : NULL, cmd->cft->root, path, fail);
-}
-
-int get_config_uint32(const struct config_node *cn, const char *path,
-		      uint32_t *result)
-{
-	const struct config_node *n;
-
-	n = find_config_node(cn, path);
-
-	if (!n || !n->v || n->v->type != CFG_INT)
-		return 0;
-
-	*result = n->v->v.i;
-	return 1;
-}
-
-int get_config_uint64(const struct config_node *cn, const char *path,
-		      uint64_t *result)
-{
-	const struct config_node *n;
-
-	n = find_config_node(cn, path);
-
-	if (!n || !n->v || n->v->type != CFG_INT)
-		return 0;
-
-	*result = (uint64_t) n->v->v.i;
-	return 1;
-}
-
-int get_config_str(const struct config_node *cn, const char *path,
-		   const char **result)
-{
-	const struct config_node *n;
-
-	n = find_config_node(cn, path);
-
-	if (!n || !n->v || n->v->type != CFG_STRING)
-		return 0;
-
-	*result = n->v->v.str;
-	return 1;
+	return dm_config_tree_find_bool(_setup_context_tree(cmd), path, fail);
 }
 
 /* Insert cn2 after cn1 */
-static void _insert_config_node(struct config_node **cn1,
-				struct config_node *cn2)
+static void _insert_config_node(struct dm_config_node **cn1,
+				struct dm_config_node *cn2)
 {
 	if (!*cn1) {
 		*cn1 = cn2;
@@ -1180,10 +205,10 @@
  * Merge section cn2 into section cn1 (which has the same name)
  * overwriting any existing cn1 nodes with matching names.
  */
-static void _merge_section(struct config_node *cn1, struct config_node *cn2)
+static void _merge_section(struct dm_config_node *cn1, struct dm_config_node *cn2)
 {
-	struct config_node *cn, *nextn, *oldn;
-	struct config_value *cv;
+	struct dm_config_node *cn, *nextn, *oldn;
+	struct dm_config_value *cv;
 
 	for (cn = cn2->child; cn; cn = nextn) {
 		nextn = cn->sib;
@@ -1197,7 +222,7 @@
 			/* Ignore - we don't have any of these yet */
 			continue;
 		/* Not already present? */
-		if (!(oldn = (struct config_node*)find_config_node(cn1->child, cn->key))) {
+		if (!(oldn = (struct dm_config_node*)dm_config_find_node(cn1->child, cn->key))) {
 			_insert_config_node(&cn1->child, cn);
 			continue;
 		}
@@ -1217,13 +242,13 @@
 	}
 }
 
-static int _match_host_tags(struct dm_list *tags, const struct config_node *tn)
+static int _match_host_tags(struct dm_list *tags, const struct dm_config_node *tn)
 {
-	const struct config_value *tv;
+	const struct dm_config_value *tv;
 	const char *str;
 
 	for (tv = tn->v; tv; tv = tv->next) {
-		if (tv->type != CFG_STRING)
+		if (tv->type != DM_CFG_STRING)
 			continue;
 		str = tv->v.str;
 		if (*str == '@')
@@ -1238,12 +263,12 @@
 }
 
 /* Destructively merge a new config tree into an existing one */
-int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
-		      struct config_tree *newdata)
+int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
+		      struct dm_config_tree *newdata)
 {
-	const struct config_node *root = cft->root;
-	struct config_node *cn, *nextn, *oldn, *cn2;
-	const struct config_node *tn;
+	const struct dm_config_node *root = cft->root;
+	struct dm_config_node *cn, *nextn, *oldn, *cn2;
+	const struct dm_config_node *tn;
 
 	for (cn = newdata->root; cn; cn = nextn) {
 		nextn = cn->sib;
@@ -1251,11 +276,11 @@
 		if (!strcmp(cn->key, "tags"))
 			continue;
 		/* If there's a tags node, skip if host tags don't match */
-		if ((tn = find_config_node(cn->child, "tags"))) {
+		if ((tn = dm_config_find_node(cn->child, "tags"))) {
 			if (!_match_host_tags(&cmd->tags, tn))
 				continue;
 		}
-		if (!(oldn = (struct config_node *)find_config_node(root, cn->key))) {
+		if (!(oldn = (struct dm_config_node *)dm_config_find_node(root, cn->key))) {
 			_insert_config_node(&cft->root, cn);
 			/* Remove any "tags" nodes */
 			for (cn2 = cn->child; cn2; cn2 = cn2->sib) {
@@ -1276,159 +301,3 @@
 	return 1;
 }
 
-/*
- * Convert a token type to the char it represents.
- */
-static char _token_type_to_char(int type)
-{
-	switch (type) {
-		case TOK_SECTION_B:
-			return SECTION_B_CHAR;
-		case TOK_SECTION_E:
-			return SECTION_E_CHAR;
-		default:
-			return 0;
-	}
-}
-
-/*
- * Returns:
- *  # of 'type' tokens in 'str'.
- */
-static unsigned _count_tokens(const char *str, unsigned len, int type)
-{
-	char c;
-
-	c = _token_type_to_char(type);
-
-	return count_chars(str, len, c);
-}
-
-const char *config_parent_name(const struct config_node *n)
-{
-	return (n->parent ? n->parent->key : "(root)");
-}
-/*
- * Heuristic function to make a quick guess as to whether a text
- * region probably contains a valid config "section".  (Useful for
- * scanning areas of the disk for old metadata.)
- * Config sections contain various tokens, may contain other sections
- * and strings, and are delimited by begin (type 'TOK_SECTION_B') and
- * end (type 'TOK_SECTION_E') tokens.  As a quick heuristic, we just
- * count the number of begin and end tokens, and see if they are
- * non-zero and the counts match.
- * Full validation of the section should be done with another function
- * (for example, read_config_fd).
- *
- * Returns:
- *  0 - probably is not a valid config section
- *  1 - probably _is_ a valid config section
- */
-unsigned maybe_config_section(const char *str, unsigned len)
-{
-	int begin_count;
-	int end_count;
-
-	begin_count = _count_tokens(str, len, TOK_SECTION_B);
-	end_count = _count_tokens(str, len, TOK_SECTION_E);
-
-	if (begin_count && end_count && (begin_count == end_count))
-		return 1;
-	else
-		return 0;
-}
-
-static struct config_value *_clone_config_value(struct dm_pool *mem, const struct config_value *v)
-{
-	struct config_value *new_cv;
-
-	if (!v)
-		return NULL;
-
-	if (!(new_cv = _create_value(mem))) {
-		log_error("Failed to clone config value.");
-		return NULL;
-	}
-
-	new_cv->type = v->type;
-	if (v->type == CFG_STRING) {
-		if (!(new_cv->v.str = dm_pool_strdup(mem, v->v.str))) {
-			log_error("Failed to clone config string value.");
-			return NULL;
-		}
-	} else
-		new_cv->v = v->v;
-
-	if (v->next && !(new_cv->next = _clone_config_value(mem, v->next)))
-		return_NULL;
-
-	return new_cv;
-}
-
-struct config_node *clone_config_node_with_mem(struct dm_pool *mem, const struct config_node *cn,
-					       int siblings)
-{
-	struct config_node *new_cn;
-
-	if (!cn)
-		return NULL;
-
-	if (!(new_cn = _create_node(mem))) {
-		log_error("Failed to clone config node.");
-		return NULL;
-	}
-
-	if ((cn->key && !(new_cn->key = dm_pool_strdup(mem, cn->key)))) {
-		log_error("Failed to clone config node key.");
-		return NULL;
-	}
-
-	if ((cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
-	    (cn->child && !(new_cn->child = clone_config_node_with_mem(mem, cn->child, 1))) ||
-	    (siblings && cn->sib && !(new_cn->sib = clone_config_node_with_mem(mem, cn->sib, siblings))))
-		return_NULL; /* 'new_cn' released with mem pool */
-
-	return new_cn;
-}
-
-struct config_node *clone_config_node(struct config_tree *cft, const struct config_node *node, int sib)
-{
-	struct cs *c = (struct cs *) cft;
-	return clone_config_node_with_mem(c->mem, node, sib);
-}
-
-struct config_node *create_config_node(struct config_tree *cft, const char *key)
-{
-	struct cs *c = (struct cs *) cft;
-	struct config_node *cn;
-
-	if (!(cn = _create_node(c->mem))) {
-		log_error("Failed to create config node.");
-		return NULL;
-	}
-	if (!(cn->key = dm_pool_strdup(c->mem, key))) {
-		log_error("Failed to create config node's key.");
-		return NULL;
-	}
-	if (!(cn->v = _create_value(c->mem))) {
-		log_error("Failed to create config node's value.");
-		return NULL;
-	}
-	cn->parent = NULL;
-	cn->v->type = CFG_INT;
-	cn->v->v.i = 0;
-	cn->v->next = NULL;
-	return cn;
-}
-
-struct config_value *create_config_value(struct config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-	return _create_value(c->mem);
-}
-
-struct dm_pool *config_tree_memory(struct config_tree *cft)
-{
-	struct cs *c = (struct cs *) cft;
-	return c->mem;
-}
--- LVM2/lib/config/config.h	2011/07/19 19:11:24	1.35
+++ LVM2/lib/config/config.h	2011/08/30 14:55:16	1.36
@@ -21,76 +21,26 @@
 struct device;
 struct cmd_context;
 
-enum {
-	CFG_STRING,
-	CFG_FLOAT,
-	CFG_INT,
-	CFG_EMPTY_ARRAY
-};
-
-struct config_value {
-	int type;
-	union {
-		int64_t i;
-		float r;
-		const char *str;
-	} v;
-	struct config_value *next;	/* for arrays */
-};
-
-struct config_node {
-	const char *key;
-	struct config_node *parent, *sib, *child;
-	struct config_value *v;
-};
-
-struct config_tree {
-	struct config_node *root;
-};
-
-struct config_tree_list {
-	struct dm_list list;
-	struct config_tree *cft;
-};
-
-struct config_tree *create_config_tree(const char *filename, int keep_open);
-struct config_tree *create_config_tree_from_string(const char *config_settings);
-
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);
-void destroy_config_tree(struct config_tree *cft);
+void destroy_config_tree(struct dm_config_tree *cft);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
-int read_config_fd(struct config_tree *cft, struct device *dev,
+int read_config_fd(struct dm_config_tree *cft, struct device *dev,
 		   off_t offset, size_t size, off_t offset2, size_t size2,
 		   checksum_fn_t checksum_fn, uint32_t checksum);
 
-int read_config_file(struct config_tree *cft);
-int write_config_file(struct config_tree *cft, const char *file,
-		      int argc, char **argv);
-
-typedef int (*putline_fn)(const char *line, void *baton);
-int write_config_node(const struct config_node *cn, putline_fn putline, void *baton);
-
-time_t config_file_timestamp(struct config_tree *cft);
-int config_file_changed(struct config_tree *cft);
-int merge_config_tree(struct cmd_context *cmd, struct config_tree *cft,
-		      struct config_tree *newdata);
-
-const struct config_node *find_config_node(const struct config_node *cn,
-					   const char *path);
-const char *find_config_str(const struct config_node *cn, const char *path,
-			    const char *fail);
-int find_config_int(const struct config_node *cn, const char *path, int fail);
-float find_config_float(const struct config_node *cn, const char *path,
-			float fail);
+int read_config_file(struct dm_config_tree *cft);
+
+int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
+		      struct dm_config_tree *newdata);
 
 /*
  * These versions check an override tree, if present, first.
  */
-const struct config_node *find_config_tree_node(struct cmd_context *cmd,
-						const char *path);
+const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
+						   const char *path);
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail);
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
@@ -100,34 +50,6 @@
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail);
 
-/*
- * Understands (0, ~0), (y, n), (yes, no), (on,
- * off), (true, false).
- */
-int find_config_bool(const struct config_node *cn, const char *path, int fail);
 int find_config_tree_bool(struct cmd_context *cmd, const char *path, int fail);
 
-int get_config_uint32(const struct config_node *cn, const char *path,
-		      uint32_t *result);
-
-int get_config_uint64(const struct config_node *cn, const char *path,
-		      uint64_t *result);
-
-int get_config_str(const struct config_node *cn, const char *path,
-		   const char **result);
-
-unsigned maybe_config_section(const char *str, unsigned len);
-
-const char *config_parent_name(const struct config_node *n);
-
-struct config_node *clone_config_node_with_mem(struct dm_pool *mem,
-					       const struct config_node *node,
-					       int siblings);
-struct config_node *create_config_node(struct config_tree *cft, const char *key);
-struct config_value *create_config_value(struct config_tree *cft);
-struct config_node *clone_config_node(struct config_tree *cft, const struct config_node *cn,
-				      int siblings);
-
-struct dm_pool *config_tree_memory(struct config_tree *cft);
-
 #endif
--- LVM2/lib/device/dev-cache.c	2011/04/28 19:59:17	1.65
+++ LVM2/lib/device/dev-cache.c	2011/08/30 14:55:16	1.66
@@ -644,8 +644,8 @@
 
 static int _init_preferred_names(struct cmd_context *cmd)
 {
-	const struct config_node *cn;
-	const struct config_value *v;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *v;
 	struct dm_pool *scratch = NULL;
 	const char **regex;
 	unsigned count = 0;
@@ -654,14 +654,14 @@
 	_cache.preferred_names_matcher = NULL;
 
 	if (!(cn = find_config_tree_node(cmd, "devices/preferred_names")) ||
-	    cn->v->type == CFG_EMPTY_ARRAY) {
+	    cn->v->type == DM_CFG_EMPTY_ARRAY) {
 		log_very_verbose("devices/preferred_names not found in config file: "
 				 "using built-in preferences");
 		return 1;
 	}
 
 	for (v = cn->v; v; v = v->next) {
-		if (v->type != CFG_STRING) {
+		if (v->type != DM_CFG_STRING) {
 			log_error("preferred_names patterns must be enclosed in quotes");
 			return 0;
 		}
--- LVM2/lib/filters/filter-persistent.c	2011/05/12 12:42:48	1.50
+++ LVM2/lib/filters/filter-persistent.c	2011/08/30 14:55:16	1.51
@@ -64,13 +64,13 @@
 	return 1;
 }
 
-static int _read_array(struct pfilter *pf, struct config_tree *cft,
+static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
 		       const char *path, void *data)
 {
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 
-	if (!(cn = find_config_node(cft->root, path))) {
+	if (!(cn = dm_config_find_node(cft->root, path))) {
 		log_very_verbose("Couldn't find %s array in '%s'",
 				 path, pf->file);
 		return 0;
@@ -81,7 +81,7 @@
 	 * devices as we go.
 	 */
 	for (cv = cn->v; cv; cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_verbose("Devices array contains a value "
 				    "which is not a string ... ignoring");
 			continue;
@@ -96,10 +96,10 @@
 	return 1;
 }
 
-int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out)
+int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 	struct stat info;
 	int r = 0;
 
@@ -122,7 +122,7 @@
 		return_0;
 	}
 
-	if (!(cft = create_config_tree(pf->file, 1)))
+	if (!(cft = dm_config_create(pf->file, 1)))
 		return_0;
 
 	if (!read_config_file(cft))
@@ -173,7 +173,7 @@
 			first = 0;
 		}
 
-		escape_double_quotes(buf, dm_hash_get_key(pf->devices, n));
+		dm_escape_double_quotes(buf, dm_hash_get_key(pf->devices, n));
 		fprintf(fp, "\t\t\"%s\"", buf);
 	}
 
@@ -186,7 +186,7 @@
 	struct pfilter *pf;
 	char *tmp_file;
 	struct stat info, info2;
-	struct config_tree *cft = NULL;
+	struct dm_config_tree *cft = NULL;
 	FILE *fp;
 	int lockfd;
 	int r = 0;
--- LVM2/lib/filters/filter-persistent.h	2010/05/13 13:04:05	1.7
+++ LVM2/lib/filters/filter-persistent.h	2011/08/30 14:55:17	1.8
@@ -22,7 +22,7 @@
 					    const char *file);
 
 int persistent_filter_wipe(struct dev_filter *f);
-int persistent_filter_load(struct dev_filter *f, struct config_tree **cft_out);
+int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
 int persistent_filter_dump(struct dev_filter *f, int merge_existing);
 
 #endif
--- LVM2/lib/filters/filter-regex.c	2011/02/18 14:47:30	1.31
+++ LVM2/lib/filters/filter-regex.c	2011/08/30 14:55:17	1.32
@@ -87,10 +87,10 @@
 	return 1;
 }
 
-static int _build_matcher(struct rfilter *rf, const struct config_value *val)
+static int _build_matcher(struct rfilter *rf, const struct dm_config_value *val)
 {
 	struct dm_pool *scratch;
-	const struct config_value *v;
+	const struct dm_config_value *v;
 	char **regex;
 	unsigned count = 0;
 	int i, r = 0;
@@ -102,7 +102,7 @@
 	 * count how many patterns we have.
 	 */
 	for (v = val; v; v = v->next) {
-		if (v->type != CFG_STRING) {
+		if (v->type != DM_CFG_STRING) {
 			log_error("Filter patterns must be enclosed in quotes.");
 			goto out;
 		}
@@ -188,7 +188,7 @@
 	dm_pool_destroy(rf->mem);
 }
 
-struct dev_filter *regex_filter_create(const struct config_value *patterns)
+struct dev_filter *regex_filter_create(const struct dm_config_value *patterns)
 {
 	struct dm_pool *mem = dm_pool_create("filter regex", 10 * 1024);
 	struct rfilter *rf;
--- LVM2/lib/filters/filter-regex.h	2010/12/20 13:12:56	1.4
+++ LVM2/lib/filters/filter-regex.h	2011/08/30 14:55:17	1.5
@@ -27,6 +27,6 @@
  * r|.*|             - reject everything else
  */
 
-struct dev_filter *regex_filter_create(const struct config_value *patterns);
+struct dev_filter *regex_filter_create(const struct dm_config_value *patterns);
 
 #endif
--- LVM2/lib/filters/filter.c	2011/05/24 13:36:58	1.62
+++ LVM2/lib/filters/filter.c	2011/08/30 14:55:17	1.63
@@ -177,7 +177,7 @@
 	return ret;
 }
 
-static int _scan_proc_dev(const char *proc, const struct config_node *cn)
+static int _scan_proc_dev(const char *proc, const struct dm_config_node *cn)
 {
 	char line[80];
 	char proc_devices[PATH_MAX];
@@ -186,7 +186,7 @@
 	int line_maj = 0;
 	int blocksection = 0;
 	size_t dev_len = 0;
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 	const char *name;
 
 
@@ -269,7 +269,7 @@
 
 		/* Check devices/types for local variations */
 		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != CFG_STRING) {
+			if (cv->type != DM_CFG_STRING) {
 				log_error("Expecting string in devices/types "
 					  "in config file");
 				if (fclose(pd))
@@ -279,7 +279,7 @@
 			dev_len = strlen(cv->v.str);
 			name = cv->v.str;
 			cv = cv->next;
-			if (!cv || cv->type != CFG_INT) {
+			if (!cv || cv->type != DM_CFG_INT) {
 				log_error("Max partition count missing for %s "
 					  "in devices/types in config file",
 					  name);
@@ -316,7 +316,7 @@
 }
 
 struct dev_filter *lvm_type_filter_create(const char *proc,
-					  const struct config_node *cn)
+					  const struct dm_config_node *cn)
 {
 	struct dev_filter *f;
 
--- LVM2/lib/filters/filter.h	2010/07/02 02:09:57	1.18
+++ LVM2/lib/filters/filter.h	2011/08/30 14:55:17	1.19
@@ -31,7 +31,7 @@
 #endif
 
 struct dev_filter *lvm_type_filter_create(const char *proc,
-					  const struct config_node *cn);
+					  const struct dm_config_node *cn);
 
 void lvm_type_filter_destroy(struct dev_filter *f);
 
--- LVM2/lib/format_text/export.c	2011/08/02 22:07:22	1.82
+++ LVM2/lib/format_text/export.c	2011/08/30 14:55:17	1.83
@@ -319,9 +319,9 @@
 	return out_text(f, "%s", line);
 }
 
-int out_config_node(struct formatter *f, const struct config_node *cn)
+int out_config_node(struct formatter *f, const struct dm_config_node *cn)
 {
-	return write_config_node(cn, _out_line, f);
+	return dm_config_write_node(cn, _out_line, f);
 }
 
 static int _print_header(struct formatter *f,
@@ -337,12 +337,12 @@
 	outf(f, FORMAT_VERSION_FIELD " = %d", FORMAT_VERSION_VALUE);
 	outnl(f);
 
-	if (!(buf = alloca(escaped_len(desc)))) {
+	if (!(buf = alloca(dm_escaped_len(desc)))) {
 		log_error("temporary stack allocation for description"
 			  "string failed");
 		return 0;
 	}
-	outf(f, "description = \"%s\"", escape_double_quotes(buf, desc));
+	outf(f, "description = \"%s\"", dm_escape_double_quotes(buf, desc));
 	outnl(f);
 	outf(f, "creation_host = \"%s\"\t# %s %s %s %s %s", _utsname.nodename,
 	     _utsname.sysname, _utsname.nodename, _utsname.release,
@@ -465,14 +465,14 @@
 
 		outf(f, "id = \"%s\"", buffer);
 
-		if (!(buf = alloca(escaped_len(pv_dev_name(pv))))) {
+		if (!(buf = alloca(dm_escaped_len(pv_dev_name(pv))))) {
 			log_error("temporary stack allocation for device name"
 				  "string failed");
 			return 0;
 		}
 
 		outhint(f, "device = \"%s\"",
-			escape_double_quotes(buf, pv_dev_name(pv)));
+			dm_escape_double_quotes(buf, pv_dev_name(pv)));
 		outnl(f);
 
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
--- LVM2/lib/format_text/flags.c	2011/08/02 22:07:22	1.46
+++ LVM2/lib/format_text/flags.c	2011/08/30 14:55:17	1.47
@@ -140,7 +140,7 @@
 	return 1;
 }
 
-int read_flags(uint64_t *status, int type, const struct config_value *cv)
+int read_flags(uint64_t *status, int type, const struct dm_config_value *cv)
 {
 	int f;
 	uint64_t s = UINT64_C(0);
@@ -149,11 +149,11 @@
 	if (!(flags = _get_flags(type)))
 		return_0;
 
-	if (cv->type == CFG_EMPTY_ARRAY)
+	if (cv->type == DM_CFG_EMPTY_ARRAY)
 		goto out;
 
 	while (cv) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Status value is not a string.");
 			return 0;
 		}
--- LVM2/lib/format_text/format-text.c	2011/08/29 13:37:37	1.184
+++ LVM2/lib/format_text/format-text.c	2011/08/30 14:55:17	1.185
@@ -223,7 +223,7 @@
 		 * area->start to area->start+area->size is not used.
 		 * Only ~32KB seems to contain valid metadata records
 		 * (LVM2 format - format_text).  As a result, I end up with
-		 * "maybe_config_section" returning true when there's no valid
+		 * "dm_config_maybe_section" returning true when there's no valid
 		 * metadata in a sector (sectors with all nulls).
 		 */
 		if (!(buf = dm_malloc(size + size2)))
@@ -236,7 +236,7 @@
 		/*
 		 * FIXME: We could add more sophisticated metadata detection
 		 */
-		if (maybe_config_section(buf, size + size2)) {
+		if (dm_config_maybe_section(buf, size + size2)) {
 			/* FIXME: Validate region, pull out timestamp?, etc */
 			/* FIXME: Do something with this region */
 			log_verbose ("Found LVM2 metadata record at "
@@ -2277,7 +2277,7 @@
 }
 
 static int _get_config_disk_area(struct cmd_context *cmd,
-				 const struct config_node *cn, struct dm_list *raw_list)
+				 const struct dm_config_node *cn, struct dm_list *raw_list)
 {
 	struct device_area dev_area;
 	const char *id_str;
@@ -2288,21 +2288,21 @@
 		return 0;
 	}
 
-	if (!get_config_uint64(cn, "start_sector", &dev_area.start)) {
+	if (!dm_config_get_uint64(cn, "start_sector", &dev_area.start)) {
 		log_error("Missing start_sector in metadata disk_area section "
 			  "of config file");
 		return 0;
 	}
 	dev_area.start <<= SECTOR_SHIFT;
 
-	if (!get_config_uint64(cn, "size", &dev_area.size)) {
+	if (!dm_config_get_uint64(cn, "size", &dev_area.size)) {
 		log_error("Missing size in metadata disk_area section "
 			  "of config file");
 		return 0;
 	}
 	dev_area.size <<= SECTOR_SHIFT;
 
-	if (!get_config_str(cn, "id", &id_str)) {
+	if (!dm_config_get_str(cn, "id", &id_str)) {
 		log_error("Missing uuid in metadata disk_area section "
 			  "of config file");
 		return 0;
@@ -2332,8 +2332,8 @@
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
 	struct format_type *fmt;
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 	struct mda_lists *mda_lists;
 
 	if (!(fmt = dm_malloc(sizeof(*fmt))))
@@ -2374,7 +2374,7 @@
 
 	if ((cn = find_config_tree_node(cmd, "metadata/dirs"))) {
 		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != CFG_STRING) {
+			if (cv->type != DM_CFG_STRING) {
 				log_error("Invalid string in config file: "
 					  "metadata/dirs");
 				goto err;
--- LVM2/lib/format_text/import-export.h	2010/12/20 13:12:56	1.26
+++ LVM2/lib/format_text/import-export.h	2011/08/30 14:55:17	1.27
@@ -44,14 +44,14 @@
 };
 
 struct text_vg_version_ops {
-	int (*check_version) (const struct config_tree * cf);
+	int (*check_version) (const struct dm_config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
-					 const struct config_tree *cf,
+					 const struct dm_config_tree *cf,
 					 unsigned use_cached_pvs);
-	void (*read_desc) (struct dm_pool * mem, const struct config_tree *cf,
+	void (*read_desc) (struct dm_pool * mem, const struct dm_config_tree *cf,
 			   time_t *when, char **desc);
 	const char *(*read_vgname) (const struct format_type *fmt,
-				    const struct config_tree *cft,
+				    const struct dm_config_tree *cft,
 				    struct id *vgid, uint64_t *vgstatus,
 				    char **creation_host);
 };
@@ -59,10 +59,10 @@
 struct text_vg_version_ops *text_vg_vsn1_init(void);
 
 int print_flags(uint64_t status, int type, char *buffer, size_t size);
-int read_flags(uint64_t *status, int type, const struct config_value *cv);
+int read_flags(uint64_t *status, int type, const struct dm_config_value *cv);
 
 char *alloc_printed_tags(struct dm_list *tags);
-int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv);
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 int text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
--- LVM2/lib/format_text/import.c	2011/06/17 14:39:10	1.54
+++ LVM2/lib/format_text/import.c	2011/08/30 14:55:17	1.55
@@ -43,13 +43,13 @@
 			       struct id *vgid, uint64_t *vgstatus,
 			       char **creation_host)
 {
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
 	const char *vgname = NULL;
 
 	_init_text_import();
 
-	if (!(cft = create_config_tree(NULL, 0)))
+	if (!(cft = dm_config_create(NULL, 0)))
 		return_NULL;
 
 	if ((!dev && !read_config_file(cft)) ||
@@ -86,7 +86,7 @@
 				       time_t *when, char **desc)
 {
 	struct volume_group *vg = NULL;
-	struct config_tree *cft;
+	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
 
 	_init_text_import();
@@ -94,7 +94,7 @@
 	*desc = NULL;
 	*when = 0;
 
-	if (!(cft = create_config_tree(file, 0)))
+	if (!(cft = dm_config_create(file, 0)))
 		return_NULL;
 
 	if ((!dev && !read_config_file(cft)) ||
@@ -131,7 +131,7 @@
 				 when, desc);
 }
 
-struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid)
 {
 	struct volume_group *vg = NULL;
--- LVM2/lib/format_text/import_vsn1.c	2011/08/10 20:25:30	1.90
+++ LVM2/lib/format_text/import_vsn1.c	2011/08/30 14:55:17	1.91
@@ -26,21 +26,21 @@
 #include "defaults.h"
 
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
-			   struct volume_group * vg, const struct config_node * pvn,
-			   const struct config_node * vgn,
+			   struct volume_group * vg, const struct dm_config_node * pvn,
+			   const struct dm_config_node * vgn,
 			   struct dm_hash_table * pv_hash,
 			   struct dm_hash_table * lv_hash,
 			   unsigned *scan_done_once,
 			   unsigned report_missing_devices);
 
 #define _read_int32(root, path, result) \
-	get_config_uint32(root, path, (uint32_t *) result)
+	dm_config_get_uint32(root, path, (uint32_t *) result)
 
 #define _read_uint32(root, path, result) \
-	get_config_uint32(root, path, result)
+	dm_config_get_uint32(root, path, result)
 
 #define _read_int64(root, path, result) \
-	get_config_uint64(root, path, result)
+	dm_config_get_uint64(root, path, result)
 
 /*
  * Logs an attempt to read an invalid format file.
@@ -54,21 +54,21 @@
  * Checks that the config file contains vg metadata, and that it
  * we recognise the version number,
  */
-static int _vsn1_check_version(const struct config_tree *cft)
+static int _vsn1_check_version(const struct dm_config_tree *cft)
 {
-	const struct config_node *cn;
-	const struct config_value *cv;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
 
 	/*
 	 * Check the contents field.
 	 */
-	if (!(cn = find_config_node(cft->root, CONTENTS_FIELD))) {
+	if (!(cn = dm_config_find_node(cft->root, CONTENTS_FIELD))) {
 		_invalid_format("missing contents field");
 		return 0;
 	}
 
 	cv = cn->v;
-	if (!cv || cv->type != CFG_STRING || strcmp(cv->v.str, CONTENTS_VALUE)) {
+	if (!cv || cv->type != DM_CFG_STRING || strcmp(cv->v.str, CONTENTS_VALUE)) {
 		_invalid_format("unrecognised contents field");
 		return 0;
 	}
@@ -76,13 +76,13 @@
 	/*
 	 * Check the version number.
 	 */
-	if (!(cn = find_config_node(cft->root, FORMAT_VERSION_FIELD))) {
+	if (!(cn = dm_config_find_node(cft->root, FORMAT_VERSION_FIELD))) {
 		_invalid_format("missing version number");
 		return 0;
 	}
 
 	cv = cn->v;
-	if (!cv || cv->type != CFG_INT || cv->v.i != FORMAT_VERSION_VALUE) {
+	if (!cv || cv->type != DM_CFG_INT || cv->v.i != FORMAT_VERSION_VALUE) {
 		_invalid_format("unrecognised version number");
 		return 0;
 	}
@@ -106,11 +106,11 @@
 	return 0;
 }
 
-static int _read_id(struct id *id, const struct config_node *cn, const char *path)
+static int _read_id(struct id *id, const struct dm_config_node *cn, const char *path)
 {
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 
-	if (!(cn = find_config_node(cn, path))) {
+	if (!(cn = dm_config_find_node(cn, path))) {
 		log_error("Couldn't find uuid.");
 		return 0;
 	}
@@ -129,12 +129,12 @@
 	return 1;
 }
 
-static int _read_flag_config(const struct config_node *n, uint64_t *status, int type)
+static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, int type)
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	*status = 0;
 
-	if (!(cn = find_config_node(n, "status"))) {
+	if (!(cn = dm_config_find_node(n, "status"))) {
 		log_error("Could not find status flags.");
 		return 0;
 	}
@@ -144,7 +144,7 @@
 		return 0;
 	}
 
-	if ((cn = find_config_node(n, "flags"))) {
+	if ((cn = dm_config_find_node(n, "flags"))) {
 		if (!(read_flags(status, type, cn->v))) {
 			log_error("Could not read flags.");
 			return 0;
@@ -155,8 +155,8 @@
 }
 
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
-		    struct volume_group *vg, const struct config_node *pvn,
-		    const struct config_node *vgn __attribute__((unused)),
+		    struct volume_group *vg, const struct dm_config_node *pvn,
+		    const struct dm_config_node *vgn __attribute__((unused)),
 		    struct dm_hash_table *pv_hash,
 		    struct dm_hash_table *lv_hash __attribute__((unused)),
 		    unsigned *scan_done_once,
@@ -164,7 +164,7 @@
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	uint64_t size;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -238,7 +238,7 @@
 	dm_list_init(&pv->segments);
 
 	/* Optional tags */
-	if ((cn = find_config_node(pvn, "tags")) &&
+	if ((cn = dm_config_find_node(pvn, "tags")) &&
 	    !(read_tags(mem, &pv->tags, cn->v))) {
 		log_error("Couldn't read tags for physical volume %s in %s.",
 			  pv_dev_name(pv), vg->name);
@@ -292,13 +292,13 @@
 }
 
 static int _read_segment(struct dm_pool *mem, struct volume_group *vg,
-			 struct logical_volume *lv, const struct config_node *sn,
+			 struct logical_volume *lv, const struct dm_config_node *sn,
 			 struct dm_hash_table *pv_hash)
 {
 	uint32_t area_count = 0u;
 	struct lv_segment *seg;
-	const struct config_node *cn, *sn_child = sn->child;
-	const struct config_value *cv;
+	const struct dm_config_node *cn, *sn_child = sn->child;
+	const struct dm_config_value *cv;
 	uint32_t start_extent, extent_count;
 	struct segment_type *segtype;
 	const char *segtype_str;
@@ -322,7 +322,7 @@
 
 	segtype_str = "striped";
 
-	if ((cn = find_config_node(sn_child, "type"))) {
+	if ((cn = dm_config_find_node(sn_child, "type"))) {
 		cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("Segment type must be a string.");
@@ -350,7 +350,7 @@
 		return_0;
 
 	/* Optional tags */
-	if ((cn = find_config_node(sn_child, "tags")) &&
+	if ((cn = dm_config_find_node(sn_child, "tags")) &&
 	    !(read_tags(mem, &seg->tags, cn->v))) {
 		log_error("Couldn't read tags for a segment of %s/%s.",
 			  vg->name, lv->name);
@@ -377,15 +377,15 @@
 	return 1;
 }
 
-int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
-		      const struct config_node *cn, struct dm_hash_table *pv_hash,
+int text_import_areas(struct lv_segment *seg, const struct dm_config_node *sn,
+		      const struct dm_config_node *cn, struct dm_hash_table *pv_hash,
 		      uint64_t status)
 {
 	unsigned int s;
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 	struct logical_volume *lv1;
 	struct physical_volume *pv;
-	const char *seg_name = config_parent_name(sn);
+	const char *seg_name = dm_config_parent_name(sn);
 
 	if (!seg->area_count) {
 		log_error("Zero areas not allowed for segment %s", seg_name);
@@ -395,7 +395,7 @@
 	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
 
 		/* first we read the pv */
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Bad volume name in areas array for segment %s.", seg_name);
 			return 0;
 		}
@@ -405,7 +405,7 @@
 			return 0;
 		}
 
-		if (cv->next->type != CFG_INT) {
+		if (cv->next->type != DM_CFG_INT) {
 			log_error("Bad offset in areas array for segment %s.", seg_name);
 			return 0;
 		}
@@ -442,10 +442,10 @@
 }
 
 static int _read_segments(struct dm_pool *mem, struct volume_group *vg,
-			  struct logical_volume *lv, const struct config_node *lvn,
+			  struct logical_volume *lv, const struct dm_config_node *lvn,
 			  struct dm_hash_table *pv_hash)
 {
-	const struct config_node *sn;
+	const struct dm_config_node *sn;
 	int count = 0, seg_count;
 
 	for (sn = lvn; sn; sn = sn->sib) {
@@ -495,15 +495,15 @@
 
 static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 			 struct dm_pool *mem,
-			 struct volume_group *vg, const struct config_node *lvn,
-			 const struct config_node *vgn __attribute__((unused)),
+			 struct volume_group *vg, const struct dm_config_node *lvn,
+			 const struct dm_config_node *vgn __attribute__((unused)),
 			 struct dm_hash_table *pv_hash __attribute__((unused)),
 			 struct dm_hash_table *lv_hash,
 			 unsigned *scan_done_once __attribute__((unused)),
 			 unsigned report_missing_devices __attribute__((unused)))
 {
 	struct logical_volume *lv;
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
 	if (!(lv = alloc_lv(mem)))
 		return_0;
@@ -523,8 +523,8 @@
 	}
 
 	lv->alloc = ALLOC_INHERIT;
-	if ((cn = find_config_node(lvn, "allocation_policy"))) {
-		const struct config_value *cv = cn->v;
+	if ((cn = dm_config_find_node(lvn, "allocation_policy"))) {
+		const struct dm_config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			return 0;
@@ -554,7 +554,7 @@
 	}
 
 	/* Optional tags */
-	if ((cn = find_config_node(lvn, "tags")) &&
+	if ((cn = dm_config_find_node(lvn, "tags")) &&
 	    !(read_tags(mem, &lv->tags, cn->v))) {
 		log_error("Couldn't read tags for logical volume %s/%s.",
 			  vg->name, lv->name);
@@ -569,8 +569,8 @@
 
 static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 			struct dm_pool *mem,
-			struct volume_group *vg, const struct config_node *lvn,
-			const struct config_node *vgn __attribute__((unused)),
+			struct volume_group *vg, const struct dm_config_node *lvn,
+			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
 			struct dm_hash_table *lv_hash,
 			unsigned *scan_done_once __attribute__((unused)),
@@ -623,17 +623,17 @@
 static int _read_sections(struct format_instance *fid,
 			  const char *section, section_fn fn,
 			  struct dm_pool *mem,
-			  struct volume_group *vg, const struct config_node *vgn,
+			  struct volume_group *vg, const struct dm_config_node *vgn,
 			  struct dm_hash_table *pv_hash,
 			  struct dm_hash_table *lv_hash,
 			  int optional,
 			  unsigned *scan_done_once)
 {
-	const struct config_node *n;
+	const struct dm_config_node *n;
 	/* Only report missing devices when doing a scan */
 	unsigned report_missing_devices = scan_done_once ? !*scan_done_once : 1;
 
-	if (!(n = find_config_node(vgn, section))) {
+	if (!(n = dm_config_find_node(vgn, section))) {
 		if (!optional) {
 			log_error("Couldn't find section '%s'.", section);
 			return 0;
@@ -652,10 +652,10 @@
 }
 
 static struct volume_group *_read_vg(struct format_instance *fid,
-				     const struct config_tree *cft,
+				     const struct dm_config_tree *cft,
 				     unsigned use_cached_pvs)
 {
-	const struct config_node *vgn, *cn;
+	const struct dm_config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
 	unsigned scan_done_once = use_cached_pvs;
@@ -677,7 +677,7 @@
 
 	vgn = vgn->child;
 
-	if ((cn = find_config_node(vgn, "system_id")) && cn->v) {
+	if ((cn = dm_config_find_node(vgn, "system_id")) && cn->v) {
 		if (!cn->v->v.str) {
 			log_error("system_id must be a string");
 			goto bad;
@@ -725,8 +725,8 @@
 		goto bad;
 	}
 
-	if ((cn = find_config_node(vgn, "allocation_policy"))) {
-		const struct config_value *cv = cn->v;
+	if ((cn = dm_config_find_node(vgn, "allocation_policy"))) {
+		const struct dm_config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
 			log_error("allocation_policy must be a string.");
 			goto bad;
@@ -760,7 +760,7 @@
 	}
 
 	/* Optional tags */
-	if ((cn = find_config_node(vgn, "tags")) &&
+	if ((cn = dm_config_find_node(vgn, "tags")) &&
 	    !(read_tags(vg->vgmem, &vg->tags, cn->v))) {
 		log_error("Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
@@ -819,33 +819,33 @@
 }
 
 static void _read_desc(struct dm_pool *mem,
-		       const struct config_tree *cft, time_t *when, char **desc)
+		       const struct dm_config_tree *cft, time_t *when, char **desc)
 {
 	const char *d;
 	unsigned int u = 0u;
 	int old_suppress;
 
 	old_suppress = log_suppress(1);
-	d = find_config_str(cft->root, "description", "");
+	d = dm_config_find_str(cft->root, "description", "");
 	log_suppress(old_suppress);
 	*desc = dm_pool_strdup(mem, d);
 
-	(void) get_config_uint32(cft->root, "creation_time", &u);
+	(void) dm_config_get_uint32(cft->root, "creation_time", &u);
 	*when = u;
 }
 
 static const char *_read_vgname(const struct format_type *fmt,
-				const struct config_tree *cft, struct id *vgid,
+				const struct dm_config_tree *cft, struct id *vgid,
 				uint64_t *vgstatus, char **creation_host)
 {
-	const struct config_node *vgn;
+	const struct dm_config_node *vgn;
 	struct dm_pool *mem = fmt->cmd->mem;
 	char *vgname;
 	int old_suppress;
 
 	old_suppress = log_suppress(2);
 	*creation_host = dm_pool_strdup(mem,
-					find_config_str(cft->root,
+					dm_config_find_str(cft->root,
 							"creation_host", ""));
 	log_suppress(old_suppress);
 
--- LVM2/lib/format_text/tags.c	2010/12/20 13:12:56	1.10
+++ LVM2/lib/format_text/tags.c	2011/08/30 14:55:17	1.11
@@ -61,13 +61,13 @@
 	return_NULL;
 }
 
-int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct config_value *cv)
+int read_tags(struct dm_pool *mem, struct dm_list *tags, const struct dm_config_value *cv)
 {
-	if (cv->type == CFG_EMPTY_ARRAY)
+	if (cv->type == DM_CFG_EMPTY_ARRAY)
 		return 1;
 
 	while (cv) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Found a tag that is not a string");
 			return 0;
 		}
--- LVM2/lib/format_text/text_export.h	2010/01/07 14:45:28	1.8
+++ LVM2/lib/format_text/text_export.h	2011/08/30 14:55:17	1.9
@@ -24,7 +24,7 @@
 
 struct formatter;
 struct lv_segment;
-struct config_node;
+struct dm_config_node;
 
 int out_size(struct formatter *f, uint64_t size, const char *fmt, ...)
     __attribute__ ((format(printf, 3, 4)));
@@ -35,7 +35,7 @@
 int out_text(struct formatter *f, const char *fmt, ...)
     __attribute__ ((format(printf, 2, 3)));
 
-int out_config_node(struct formatter *f, const struct config_node *cn);
+int out_config_node(struct formatter *f, const struct dm_config_node *cn);
 
 int out_areas(struct formatter *f, const struct lv_segment *seg,
 	      const char *type);
--- LVM2/lib/format_text/text_import.h	2009/12/04 17:48:32	1.5
+++ LVM2/lib/format_text/text_import.h	2011/08/30 14:55:17	1.6
@@ -17,10 +17,10 @@
 #define _LVM_TEXT_IMPORT_H
 
 struct lv_segment;
-struct config_node;
+struct dm_config_node;
 
-int text_import_areas(struct lv_segment *seg, const struct config_node *sn,
-		      const struct config_node *cn, struct dm_hash_table *pv_hash,
+int text_import_areas(struct lv_segment *seg, const struct dm_config_node *sn,
+		      const struct dm_config_node *cn, struct dm_hash_table *pv_hash,
 		      uint64_t status);
 
 #endif
--- LVM2/lib/locking/cluster_locking.c	2011/08/09 11:44:57	1.57
+++ LVM2/lib/locking/cluster_locking.c	2011/08/30 14:55:17	1.58
@@ -36,7 +36,7 @@
 int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags);
 int query_resource(const char *resource, int *mode);
 void locking_end(void);
-int locking_init(int type, struct config_tree *cf, uint32_t *flags);
+int locking_init(int type, struct dm_config_tree *cf, uint32_t *flags);
 #endif
 
 typedef struct lvm_response {
@@ -606,7 +606,7 @@
 	return 1;
 }
 #else
-int locking_init(int type, struct config_tree *cf, uint32_t *flags)
+int locking_init(int type, struct dm_config_tree *cf, uint32_t *flags)
 {
 	_clvmd_sock = _open_local_sock(0);
 	if (_clvmd_sock == -1)
--- LVM2/lib/locking/external_locking.c	2011/08/09 11:44:57	1.19
+++ LVM2/lib/locking/external_locking.c	2011/08/30 14:55:17	1.20
@@ -26,7 +26,7 @@
 static void (*_end_fn) (void) = NULL;
 static int (*_lock_fn) (struct cmd_context * cmd, const char *resource,
 			uint32_t flags) = NULL;
-static int (*_init_fn) (int type, struct config_tree * cft,
+static int (*_init_fn) (int type, struct dm_config_tree * cft,
 			uint32_t *flags) = NULL;
 static int (*_lock_query_fn) (const char *resource, int *mode) = NULL;
 
--- LVM2/lib/metadata/lv_manip.c	2011/08/19 22:55:07	1.276
+++ LVM2/lib/metadata/lv_manip.c	2011/08/30 14:55:17	1.277
@@ -628,7 +628,7 @@
 	 */
 	unsigned alloc_and_split_meta;
 
-	const struct config_node *cling_tag_list_cn;
+	const struct dm_config_node *cling_tag_list_cn;
 
 	struct dm_list *parallel_areas;	/* PVs to avoid */
 
@@ -1161,7 +1161,7 @@
 	struct pv_area_used *areas;
 	struct pv_area *pva;
 	uint32_t areas_size;
-	const struct config_node *cling_tag_list_cn;
+	const struct dm_config_node *cling_tag_list_cn;
 	int s;	/* Area index of match */
 };
 
@@ -1182,12 +1182,12 @@
  */
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
 {
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
 
 	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Ignoring invalid string in config file entry "
 				  "allocation/cling_tag_list");
 			continue;
@@ -1292,7 +1292,7 @@
  * Is pva on same PV as any existing areas?
  */
 static int _check_cling(struct alloc_handle *ah,
-			const struct config_node *cling_tag_list_cn,
+			const struct dm_config_node *cling_tag_list_cn,
 			struct lv_segment *prev_lvseg, struct pv_area *pva,
 			struct alloc_state *alloc_state)
 {
--- LVM2/lib/metadata/metadata.c	2011/08/11 17:34:31	1.465
+++ LVM2/lib/metadata/metadata.c	2011/08/30 14:55:17	1.466
@@ -687,7 +687,7 @@
 			log_error("Failed to duplicate pv name %s.", pv_names[i]);
 			return 0;
 		}
-		unescape_colons_and_at_signs(pv_name, NULL, NULL);
+		dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
 		if (!vg_extend_single_pv(vg, pv_name, pp)) {
 			log_error("Unable to add physical volume '%s' to "
 				  "volume group '%s'.", pv_name, vg->name);
--- LVM2/lib/metadata/metadata.h	2011/08/10 20:17:33	1.249
+++ LVM2/lib/metadata/metadata.h	2011/08/30 14:55:17	1.250
@@ -98,7 +98,7 @@
 //#define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 //#define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
-struct config_tree;
+struct dm_config_tree;
 struct metadata_area;
 
 /* Per-format per-metadata area operations */
@@ -455,9 +455,10 @@
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
+int export_vg_to_config_tree(struct volume_group *vg, struct dm_config_tree **cft);
 struct volume_group *import_vg_from_buffer(const char *buf,
 					   struct format_instance *fid);
-struct volume_group *import_vg_from_config_tree(const struct config_tree *cft,
+struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid);
 
 /*
--- LVM2/lib/metadata/mirror.c	2011/07/19 16:37:42	1.158
+++ LVM2/lib/metadata/mirror.c	2011/08/30 14:55:17	1.159
@@ -1179,13 +1179,13 @@
 	const char *policy;
 
 	if (log_policy)
-		policy = find_config_str(NULL, "activation/mirror_log_fault_policy",
+		policy = dm_config_find_str(NULL, "activation/mirror_log_fault_policy",
 					 DEFAULT_MIRROR_LOG_FAULT_POLICY);
 	else {
-		policy = find_config_str(NULL, "activation/mirror_image_fault_policy",
+		policy = dm_config_find_str(NULL, "activation/mirror_image_fault_policy",
 					 NULL);
 		if (!policy)
-			policy = find_config_str(NULL, "activation/mirror_device_fault_policy",
+			policy = dm_config_find_str(NULL, "activation/mirror_device_fault_policy",
 						 DEFAULT_MIRROR_IMAGE_FAULT_POLICY);
 	}
 
--- LVM2/lib/metadata/segtype.h	2011/08/26 18:17:05	1.41
+++ LVM2/lib/metadata/segtype.h	2011/08/30 14:55:17	1.42
@@ -20,11 +20,11 @@
 
 struct segtype_handler;
 struct cmd_context;
-struct config_tree;
+struct dm_config_tree;
 struct lv_segment;
 struct lv_activate_opts;
 struct formatter;
-struct config_node;
+struct dm_config_node;
 struct dev_manager;
 
 /* Feature flags */
@@ -87,10 +87,10 @@
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
-	int (*text_import_area_count) (const struct config_node * sn,
+	int (*text_import_area_count) (const struct dm_config_node * sn,
 				       uint32_t *area_count);
 	int (*text_import) (struct lv_segment * seg,
-			    const struct config_node * sn,
+			    const struct dm_config_node * sn,
 			    struct dm_hash_table * pv_hash);
 	int (*merge_segments) (struct lv_segment * seg1,
 			       struct lv_segment * seg2);
--- LVM2/lib/mirror/mirrored.c	2011/06/17 14:17:17	1.89
+++ LVM2/lib/mirror/mirrored.c	2011/08/30 14:55:17	1.90
@@ -69,46 +69,46 @@
 	log_print(" ");
 }
 
-static int _mirrored_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
+static int _mirrored_text_import_area_count(const struct dm_config_node *sn, uint32_t *area_count)
 {
-	if (!get_config_uint32(sn, "mirror_count", area_count)) {
+	if (!dm_config_get_uint32(sn, "mirror_count", area_count)) {
 		log_error("Couldn't read 'mirror_count' for "
-			  "segment '%s'.", config_parent_name(sn));
+			  "segment '%s'.", dm_config_parent_name(sn));
 		return 0;
 	}
 
 	return 1;
 }
 
-static int _mirrored_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _mirrored_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	const char *logname = NULL;
 
-	if (find_config_node(sn, "extents_moved")) {
-		if (get_config_uint32(sn, "extents_moved",
+	if (dm_config_find_node(sn, "extents_moved")) {
+		if (dm_config_get_uint32(sn, "extents_moved",
 				      &seg->extents_copied))
 			seg->status |= PVMOVE;
 		else {
 			log_error("Couldn't read 'extents_moved' for "
 				  "segment %s of logical volume %s.",
-				  config_parent_name(sn), seg->lv->name);
+				  dm_config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
 
-	if (find_config_node(sn, "region_size")) {
-		if (!get_config_uint32(sn, "region_size",
+	if (dm_config_find_node(sn, "region_size")) {
+		if (!dm_config_get_uint32(sn, "region_size",
 				      &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
 				  "segment %s of logical volume %s.",
-				  config_parent_name(sn), seg->lv->name);
+				  dm_config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
 
-	if ((cn = find_config_node(sn, "mirror_log"))) {
+	if ((cn = dm_config_find_node(sn, "mirror_log"))) {
 		if (!cn->v || !cn->v->v.str) {
 			log_error("Mirror log type must be a string.");
 			return 0;
@@ -117,7 +117,7 @@
 		if (!(seg->log_lv = find_lv(seg->lv->vg, logname))) {
 			log_error("Unrecognised mirror log in "
 				  "segment %s of logical volume %s.",
-				  config_parent_name(sn), seg->lv->name);
+				  dm_config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 		seg->log_lv->status |= MIRROR_LOG;
@@ -126,14 +126,14 @@
 	if (logname && !seg->region_size) {
 		log_error("Missing region size for mirror log for "
 			  "segment %s of logical volume %s.",
-			  config_parent_name(sn), seg->lv->name);
+			  dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
-	if (!(cn = find_config_node(sn, "mirrors"))) {
+	if (!(cn = dm_config_find_node(sn, "mirrors"))) {
 		log_error("Couldn't find mirrors array for "
 			  "segment %s of logical volume %s.",
-			  config_parent_name(sn), seg->lv->name);
+			  dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
--- LVM2/lib/misc/lvm-string.c	2011/08/02 22:07:22	1.28
+++ LVM2/lib/misc/lvm-string.c	2011/08/30 14:55:18	1.29
@@ -44,248 +44,6 @@
 }
 
 /*
- * Count occurences of 'c' in 'str' until we reach a null char.
- *
- * Returns:
- *  len - incremented for each char we encounter.
- *  count - number of occurrences of 'c' and 'c2'.
- */
-static void _count_chars(const char *str, size_t *len, int *count,
-			 const int c1, const int c2)
-{
-	const char *ptr;
-
-	for (ptr = str; *ptr; ptr++, (*len)++)
-		if (*ptr == c1 || *ptr == c2)
-			(*count)++;
-}
-
-/*
- * Count occurences of 'c' in 'str' of length 'size'.
- *
- * Returns:
- *   Number of occurrences of 'c'
- */
-unsigned count_chars(const char *str, size_t len, const int c)
-{
-	size_t i;
-	unsigned count = 0;
-
-	for (i = 0; i < len; i++)
-		if (str[i] == c)
-			count++;
-
-	return count;
-}
-
-/*
- * Length of string after escaping double quotes and backslashes.
- */
-size_t escaped_len(const char *str)
-{
-	size_t len = 1;
-	int count = 0;
-
-	_count_chars(str, &len, &count, '\"', '\\');
-
-	return count + len;
-}
-
-/*
- * Copies a string, quoting orig_char with quote_char.
- * Optionally also quote quote_char.
- */
-static void _quote_characters(char **out, const char *src,
-			      const int orig_char, const int quote_char,
-			      int quote_quote_char)
-{
-	while (*src) {
-		if (*src == orig_char ||
-		    (*src == quote_char && quote_quote_char))
-			*(*out)++ = quote_char;
-
-		*(*out)++ = *src++;
-	}
-}
-
-static void _unquote_one_character(char *src, const char orig_char,
-				   const char quote_char)
-{
-	char *out;
-	char s, n;
-
-	/* Optimise for the common case where no changes are needed. */
-	while ((s = *src++)) {
-		if (s == quote_char &&
-		    ((n = *src) == orig_char || n == quote_char)) {
-			out = src++;
-			*(out - 1) = n;
-
-			while ((s = *src++)) {
-				if (s == quote_char &&
-				    ((n = *src) == orig_char || n == quote_char)) {
-					s = n;
-					src++;
-				}
-				*out = s;
-				out++;
-			}
-
-			*out = '\0';
-			return;
-		}
-	}
-}
-
-/*
- * Unquote each character given in orig_char array and unquote quote_char
- * as well. Also save the first occurrence of each character from orig_char
- * that was found unquoted in arr_substr_first_unquoted array. This way we can
- * process several characters in one go.
- */
-static void _unquote_characters(char *src, const char *orig_chars,
-				size_t num_orig_chars,
-				const char quote_char,
-				char *arr_substr_first_unquoted[])
-{
-	char *out = src;
-	char c, s, n;
-	unsigned i;
-
-	while ((s = *src++)) {
-		for (i = 0; i < num_orig_chars; i++) {
-			c = orig_chars[i];
-			if (s == quote_char &&
-			    ((n = *src) == c || n == quote_char)) {
-				s = n;
-				src++;
-				break;
-			}
-			if (arr_substr_first_unquoted && (s == c) &&
-			    !arr_substr_first_unquoted[i])
-				arr_substr_first_unquoted[i] = out;
-		};
-		*out++ = s;
-	}
-
-	*out = '\0';
-}
-
-/*
- * Copies a string, quoting hyphens with hyphens.
- */
-static void _quote_hyphens(char **out, const char *src)
-{
-	_quote_characters(out, src, '-', '-', 0);
-}
-
-/*
- * <vg>-<lv>-<layer> or if !layer just <vg>-<lv>.
- */
-char *build_dm_name(struct dm_pool *mem, const char *vgname,
-		    const char *lvname, const char *layer)
-{
-	size_t len = 1;
-	int hyphens = 1;
-	char *r, *out;
-
-	_count_chars(vgname, &len, &hyphens, '-', 0);
-	_count_chars(lvname, &len, &hyphens, '-', 0);
-
-	if (layer && *layer) {
-		_count_chars(layer, &len, &hyphens, '-', 0);
-		hyphens++;
-	}
-
-	len += hyphens;
-
-	if (!(r = dm_pool_alloc(mem, len))) {
-		log_error("build_dm_name: Allocation failed for %" PRIsize_t
-			  " for %s %s %s.", len, vgname, lvname, layer);
-		return NULL;
-	}
-
-	out = r;
-	_quote_hyphens(&out, vgname);
-	*out++ = '-';
-	_quote_hyphens(&out, lvname);
-
-	if (layer && *layer) {
-		/* No hyphen if the layer begins with _ e.g. _mlog */
-		if (*layer != '_')
-			*out++ = '-';
-		_quote_hyphens(&out, layer);
-	}
-	*out = '\0';
-
-	return r;
-}
-
-char *build_dm_uuid(struct dm_pool *mem, const char *lvid, const char *layer)
-{
-	char *dmuuid;
-	size_t len;
-
-	if (!layer)
-		layer = "";
-
-	len = sizeof(UUID_PREFIX) + strlen(lvid) + strlen(layer) + 1;
-
-	if (!(dmuuid = dm_pool_alloc(mem, len))) {
-		log_error("build_dm_name: Allocation failed for %" PRIsize_t
-			  " %s %s.", len, lvid, layer);
-		return NULL;
-	}
-
-	sprintf(dmuuid, UUID_PREFIX "%s%s%s", lvid, (*layer) ? "-" : "", layer);
-
-	return dmuuid;
-}
-
-/*
- * Copies a string, quoting double quotes with backslashes.
- */
-char *escape_double_quotes(char *out, const char *src)
-{
-	char *buf = out;
-
-	_quote_characters(&buf, src, '\"', '\\', 1);
-	*buf = '\0';
-
-	return out;
-}
-
-/*
- * Undo quoting in situ.
- */
-void unescape_double_quotes(char *src)
-{
-	_unquote_one_character(src, '\"', '\\');
-}
-
-/*
- * Unescape colons and "at" signs in situ and save the substrings
- * starting at the position of the first unescaped colon and the
- * first unescaped "at" sign. This is normally used to unescape
- * device names used as PVs.
- */
-void unescape_colons_and_at_signs(char *src,
-				  char **substr_first_unquoted_colon,
-				  char **substr_first_unquoted_at_sign)
-{
-	const char *orig_chars = ":@";
-	char *arr_substr_first_unquoted[] = {NULL, NULL, NULL};
-
-	_unquote_characters(src, orig_chars, 2, '\\', arr_substr_first_unquoted);
-
-	if (substr_first_unquoted_colon)
-		*substr_first_unquoted_colon = arr_substr_first_unquoted[0];
-
-	if (substr_first_unquoted_at_sign)
-		*substr_first_unquoted_at_sign = arr_substr_first_unquoted[1];
-}
-
-/*
  * A-Za-z0-9._-+/=!:&#
  */
 int validate_tag(const char *n)
@@ -392,3 +150,9 @@
 
 	return rc;
 }
+
+char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
+		    const char *layer)
+{
+	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
+}
--- LVM2/lib/misc/lvm-string.h	2010/11/17 10:19:30	1.22
+++ LVM2/lib/misc/lvm-string.h	2011/08/30 14:55:18	1.23
@@ -27,8 +27,6 @@
 int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
   __attribute__ ((format(printf, 3, 4)));
 
-char *build_dm_name(struct dm_pool *mem, const char *vg,
-                    const char *lv, const char *layer);
 char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
 		    const char *layer);
 
@@ -38,36 +36,4 @@
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
 
-/*
- * Returns number of occurrences of c in first len characters of str.
- */
-unsigned count_chars(const char *str, size_t len, const int c);
-
-/*
- * Returns what length of escaped string would be including terminating NUL.
- */
-size_t escaped_len(const char *str);
-
-/*
- * Copies a string from src to out. 
- * Double quotation marks and backslashes are quoted with a backslash.
- * Caller must ensure *out has enough space - see escaped_len().
- * Returns *out.
- */
-char *escape_double_quotes(char *out, const char *src);
-
-/*
- * Removes quoting of double quotation marks and backslashes in situ.
- */
-void unescape_double_quotes(char *src);
-
-/*
- * Unescape colons and at signs in situ and save the substring starting
- * at the position of the first unescaped colon and the first unescaped
- * "at" sign.
- */
-void unescape_colons_and_at_signs(char *src,
-				  char **substr_first_unquoted_colon,
-				  char **substr_first_unquoted_at_sign);
-
 #endif
--- LVM2/lib/mm/memlock.c	2011/06/13 03:32:46	1.45
+++ LVM2/lib/mm/memlock.c	2011/08/30 14:55:18	1.46
@@ -146,10 +146,10 @@
  * mlock/munlock memory areas from /proc/self/maps
  * format described in kernel/Documentation/filesystem/proc.txt
  */
-static int _maps_line(const struct config_node *cn, lvmlock_t lock,
+static int _maps_line(const struct dm_config_node *cn, lvmlock_t lock,
 		      const char* line, size_t* mstats)
 {
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 	long from, to;
 	int pos;
 	unsigned i;
@@ -188,7 +188,7 @@
 			}
 	} else {
 		for (cv = cn->v; cv; cv = cv->next) {
-			if ((cv->type != CFG_STRING) || !cv->v.str[0])
+			if ((cv->type != DM_CFG_STRING) || !cv->v.str[0])
 				continue;
 			if (strstr(line + pos, cv->v.str)) {
 				log_debug("mlock_filter '%s' matches '%s': Skipping.",
@@ -228,7 +228,7 @@
 
 static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats)
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	char *line, *line_end;
 	size_t len;
 	ssize_t n;
--- LVM2/lib/raid/raid.c	2011/08/24 13:41:47	1.9
+++ LVM2/lib/raid/raid.c	2011/08/30 14:55:18	1.10
@@ -32,25 +32,25 @@
 	return seg->segtype->name;
 }
 
-static int _raid_text_import_area_count(const struct config_node *sn,
+static int _raid_text_import_area_count(const struct dm_config_node *sn,
 					uint32_t *area_count)
 {
-	if (!get_config_uint32(sn, "device_count", area_count)) {
+	if (!dm_config_get_uint32(sn, "device_count", area_count)) {
 		log_error("Couldn't read 'device_count' for "
-			  "segment '%s'.", config_parent_name(sn));
+			  "segment '%s'.", dm_config_parent_name(sn));
 		return 0;
 	}
 	return 1;
 }
 
 static int _raid_text_import_areas(struct lv_segment *seg,
-				   const struct config_node *sn,
-				   const struct config_node *cn)
+				   const struct dm_config_node *sn,
+				   const struct dm_config_node *cn)
 {
 	unsigned int s;
-	const struct config_value *cv;
+	const struct dm_config_value *cv;
 	struct logical_volume *lv1;
-	const char *seg_name = config_parent_name(sn);
+	const char *seg_name = dm_config_parent_name(sn);
 
 	if (!seg->area_count) {
 		log_error("No areas found for segment %s", seg_name);
@@ -58,7 +58,7 @@
 	}
 
 	for (cv = cn->v, s = 0; cv && s < seg->area_count; s++, cv = cv->next) {
-		if (cv->type != CFG_STRING) {
+		if (cv->type != DM_CFG_STRING) {
 			log_error("Bad volume name in areas array for segment %s.", seg_name);
 			return 0;
 		}
@@ -101,31 +101,31 @@
 }
 
 static int _raid_text_import(struct lv_segment *seg,
-			     const struct config_node *sn,
+			     const struct dm_config_node *sn,
 			     struct dm_hash_table *pv_hash)
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
-	if (find_config_node(sn, "region_size")) {
-		if (!get_config_uint32(sn, "region_size", &seg->region_size)) {
+	if (dm_config_find_node(sn, "region_size")) {
+		if (!dm_config_get_uint32(sn, "region_size", &seg->region_size)) {
 			log_error("Couldn't read 'region_size' for "
 				  "segment %s of logical volume %s.",
-				  config_parent_name(sn), seg->lv->name);
+				  dm_config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
-	if (find_config_node(sn, "stripe_size")) {
-		if (!get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
+	if (dm_config_find_node(sn, "stripe_size")) {
+		if (!dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
 			log_error("Couldn't read 'stripe_size' for "
 				  "segment %s of logical volume %s.",
-				  config_parent_name(sn), seg->lv->name);
+				  dm_config_parent_name(sn), seg->lv->name);
 			return 0;
 		}
 	}
-	if (!(cn = find_config_node(sn, "raids"))) {
+	if (!(cn = dm_config_find_node(sn, "raids"))) {
 		log_error("Couldn't find RAID array for "
 			  "segment %s of logical volume %s.",
-			  config_parent_name(sn), seg->lv->name);
+			  dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
--- LVM2/lib/replicator/replicator.c	2011/08/24 13:41:47	1.8
+++ LVM2/lib/replicator/replicator.c	2011/08/30 14:55:18	1.9
@@ -36,7 +36,7 @@
  */
 #define SEG_LOG_ERROR(t, p...) \
 	log_error(t " segment %s of logical volume %s.", ## p, \
-		  config_parent_name(sn), seg->lv->name), 0;
+		  dm_config_parent_name(sn), seg->lv->name), 0;
 
 
 /*
@@ -58,24 +58,24 @@
 		log_print("  Replicator volume\t%s", seg->rlog_lv->name);
 }
 
-/* Wrapper for get_config_uint32() with default value */
-static uint32_t _get_config_uint32(const struct config_node *cn,
+/* Wrapper for dm_config_get_uint32() with default value */
+static uint32_t _get_config_uint32(const struct dm_config_node *cn,
 				   const char *path,
 				   uint32_t def)
 {
 	uint32_t t;
 
-	return get_config_uint32(cn, path, &t) ? t : def;
+	return dm_config_get_uint32(cn, path, &t) ? t : def;
 }
 
-/* Wrapper for get_config_uint64() with default value */
-static uint64_t _get_config_uint64(const struct config_node *cn,
+/* Wrapper for dm_config_get_uint64() with default value */
+static uint64_t _get_config_uint64(const struct dm_config_node *cn,
 				   const char *path,
 				   uint64_t def)
 {
 	uint64_t t;
 
-	return get_config_uint64(cn, path, &t) ? t : def;
+	return dm_config_get_uint64(cn, path, &t) ? t : def;
 }
 
 
@@ -86,13 +86,13 @@
 };
 
 /* Parse state string */
-static replicator_state_t _get_state(const struct config_node *sn,
+static replicator_state_t _get_state(const struct dm_config_node *sn,
 				     const char *path, replicator_state_t def)
 {
 	const char *str;
 	unsigned i;
 
-	if (get_config_str(sn, path, &str)) {
+	if (dm_config_get_str(sn, path, &str)) {
 		for (i = 0; i < sizeof(_state_txt)/sizeof(_state_txt[0]); ++i)
 			if (strcasecmp(str, _state_txt[i]) == 0)
 				return (replicator_state_t) i;
@@ -115,13 +115,13 @@
 
 
 /* Parse action string */
-static dm_replicator_mode_t _get_op_mode(const struct config_node *sn,
+static dm_replicator_mode_t _get_op_mode(const struct dm_config_node *sn,
 					 const char *path, dm_replicator_mode_t def)
 {
 	const char *str;
 	unsigned i;
 
-	if (get_config_str(sn, path, &str)) {
+	if (dm_config_get_str(sn, path, &str)) {
 		for (i = 0; i < sizeof(_op_mode_txt)/sizeof(_op_mode_txt[0]); ++i)
 			if (strcasecmp(str, _op_mode_txt[i]) == 0) {
 				log_very_verbose("Setting %s to %s",
@@ -162,16 +162,16 @@
 /* Parse replicator site element */
 static int _add_site(struct lv_segment *seg,
 		     const char *key,
-		     const struct config_node *sn)
+		     const struct dm_config_node *sn)
 {
 	struct dm_pool *mem = seg->lv->vg->vgmem;
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	struct replicator_site *rsite;
 
 	if (!(rsite = _get_site(seg->lv, key)))
 		return_0;
 
-	if (!find_config_node(sn, "site_index"))
+	if (!dm_config_find_node(sn, "site_index"))
 		return SEG_LOG_ERROR("Mandatory site_index is missing for");
 
 	rsite->state = _get_state(sn, "state", REPLICATOR_STATE_PASSIVE);
@@ -204,8 +204,8 @@
 					      rsite->op_mode);
 	}
 
-	if ((cn = find_config_node(sn, "volume_group"))) {
-		if (!cn->v || cn->v->type != CFG_STRING)
+	if ((cn = dm_config_find_node(sn, "volume_group"))) {
+		if (!cn->v || cn->v->type != DM_CFG_STRING)
 			return SEG_LOG_ERROR("volume_group must be a string in");
 
 		if (!(rsite->vg_name = dm_pool_strdup(mem, cn->v->v.str)))
@@ -220,25 +220,25 @@
 
 /* Import replicator segment */
 static int _replicator_text_import(struct lv_segment *seg,
-				   const struct config_node *sn,
+				   const struct dm_config_node *sn,
 				   struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	struct logical_volume *rlog_lv;
 
 	if (!replicator_add_replicator_dev(seg->lv, NULL))
 		return_0;
 
-	if (!(cn = find_config_node(sn, "replicator_log")) ||
-	    !cn->v || cn->v->type != CFG_STRING)
+	if (!(cn = dm_config_find_node(sn, "replicator_log")) ||
+	    !cn->v || cn->v->type != DM_CFG_STRING)
 		return SEG_LOG_ERROR("Replicator log type must be a string in");
 
 	if (!(rlog_lv = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown replicator log %s in",
 				     cn->v->v.str);
 
-	if (!(cn = find_config_node(sn, "replicator_log_type")) ||
-	    !cn->v || cn->v->type != CFG_STRING)
+	if (!(cn = dm_config_find_node(sn, "replicator_log_type")) ||
+	    !cn->v || cn->v->type != DM_CFG_STRING)
 		return SEG_LOG_ERROR("Replicator log's type must be a string in");
 	if (strcasecmp(cn->v->v.str, "ringbuffer"))
 		return SEG_LOG_ERROR("Only ringbuffer replicator log type is supported in");
@@ -443,7 +443,7 @@
 
 static int _add_device(struct lv_segment *seg,
 		       const char *site_name,
-		       const struct config_node *sn,
+		       const struct dm_config_node *sn,
 		       uint64_t devidx)
 {
 	struct dm_pool *mem = seg->lv->vg->vgmem;
@@ -453,19 +453,19 @@
 	struct replicator_device *rdev;
 	const char *dev_str = NULL;
 	const char *slog_str = NULL;
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
 	dm_list_iterate_items(rdev, &rsite->rdevices)
 		if (rdev->replicator_dev == seg)
 			return SEG_LOG_ERROR("Duplicate site found in");
 
-	if ((cn = find_config_node(sn, "sync_log"))) {
+	if ((cn = dm_config_find_node(sn, "sync_log"))) {
 		if (!cn->v || !cn->v->v.str)
 			return SEG_LOG_ERROR("Sync log must be a string in");
 		slog_str = cn->v->v.str;
 	}
 
-	if (!(cn = find_config_node(sn, "logical_volume")) ||
+	if (!(cn = dm_config_find_node(sn, "logical_volume")) ||
 	    !cn->v || !cn->v->v.str)
 		return SEG_LOG_ERROR("Logical volume must be a string in");
 
@@ -520,14 +520,14 @@
 
 /* Import replicator segment */
 static int _replicator_dev_text_import(struct lv_segment *seg,
-				       const struct config_node *sn,
+				       const struct dm_config_node *sn,
 				       struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 	struct logical_volume *replicator;
 	uint64_t devidx;
 
-	if (!(cn = find_config_node(sn, "replicator")))
+	if (!(cn = dm_config_find_node(sn, "replicator")))
 		return SEG_LOG_ERROR("Replicator is missing for");
 
 	if (!cn->v || !cn->v->v.str)
@@ -542,8 +542,8 @@
 	log_very_verbose("replicator=%s", replicator->name);
 
 	/* Mandatory */
-	if (!find_config_node(sn, "device_index") ||
-	    !get_config_uint64(sn, "device_index", &devidx))
+	if (!dm_config_find_node(sn, "device_index") ||
+	    !dm_config_get_uint64(sn, "device_index", &devidx))
 		return SEG_LOG_ERROR("Could not read 'device_index' for");
 
 	/* Read devices from sites */
--- LVM2/lib/snapshot/snapshot.c	2011/06/17 14:22:49	1.57
+++ LVM2/lib/snapshot/snapshot.c	2011/08/30 14:55:18	1.58
@@ -37,7 +37,7 @@
 	return _snap_name(seg);
 }
 
-static int _snap_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _snap_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	uint32_t chunk_size;
@@ -45,28 +45,28 @@
 	struct logical_volume *org, *cow;
 	int old_suppress, merge = 0;
 
-	if (!get_config_uint32(sn, "chunk_size", &chunk_size)) {
+	if (!dm_config_get_uint32(sn, "chunk_size", &chunk_size)) {
 		log_error("Couldn't read chunk size for snapshot.");
 		return 0;
 	}
 
 	old_suppress = log_suppress(1);
 
-	if ((cow_name = find_config_str(sn, "merging_store", NULL))) {
-		if (find_config_str(sn, "cow_store", NULL)) {
+	if ((cow_name = dm_config_find_str(sn, "merging_store", NULL))) {
+		if (dm_config_find_str(sn, "cow_store", NULL)) {
 			log_suppress(old_suppress);
 			log_error("Both snapshot cow and merging storage were specified.");
 			return 0;
 		}
 		merge = 1;
 	}
-	else if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
+	else if (!(cow_name = dm_config_find_str(sn, "cow_store", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;
 	}
 
-	if (!(org_name = find_config_str(sn, "origin", NULL))) {
+	if (!(org_name = dm_config_find_str(sn, "origin", NULL))) {
 		log_suppress(old_suppress);
 		log_error("Snapshot origin not specified.");
 		return 0;
--- LVM2/lib/striped/striped.c	2011/06/17 14:14:20	1.37
+++ LVM2/lib/striped/striped.c	2011/08/30 14:55:18	1.38
@@ -57,32 +57,32 @@
 	log_print(" ");
 }
 
-static int _striped_text_import_area_count(const struct config_node *sn, uint32_t *area_count)
+static int _striped_text_import_area_count(const struct dm_config_node *sn, uint32_t *area_count)
 {
-	if (!get_config_uint32(sn, "stripe_count", area_count)) {
+	if (!dm_config_get_uint32(sn, "stripe_count", area_count)) {
 		log_error("Couldn't read 'stripe_count' for "
-			  "segment '%s'.", config_parent_name(sn));
+			  "segment '%s'.", dm_config_parent_name(sn));
 		return 0;
 	}
 
 	return 1;
 }
 
-static int _striped_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _striped_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
 	if ((seg->area_count != 1) &&
-	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {
+	    !dm_config_get_uint32(sn, "stripe_size", &seg->stripe_size)) {
 		log_error("Couldn't read stripe_size for segment %s "
-			  "of logical volume %s.", config_parent_name(sn), seg->lv->name);
+			  "of logical volume %s.", dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
-	if (!(cn = find_config_node(sn, "stripes"))) {
+	if (!(cn = dm_config_find_node(sn, "stripes"))) {
 		log_error("Couldn't find stripes array for segment %s "
-			  "of logical volume %s.", config_parent_name(sn), seg->lv->name);
+			  "of logical volume %s.", dm_config_parent_name(sn), seg->lv->name);
 		return 0;
 	}
 
--- LVM2/lib/thin/thin.c	2011/08/26 18:15:14	1.5
+++ LVM2/lib/thin/thin.c	2011/08/30 14:55:18	1.6
@@ -36,39 +36,39 @@
  */
 #define SEG_LOG_ERROR(t, p...) \
 	log_error(t " segment %s of logical volume %s.", ## p, \
-		  config_parent_name(sn), seg->lv->name), 0;
+		  dm_config_parent_name(sn), seg->lv->name), 0;
 
 static const char *_thin_pool_name(const struct lv_segment *seg)
 {
 	return seg->segtype->name;
 }
 
-static int _thin_pool_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _thin_pool_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_node(sn, "data")) ||
-	    !cn->v || cn->v->type != CFG_STRING)
+	if (!(cn = dm_config_find_node(sn, "data")) ||
+	    !cn->v || cn->v->type != DM_CFG_STRING)
 		return SEG_LOG_ERROR("Thin pool data must be a string in");
 
 	if (!(seg->data_lv = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown pool data %s in",
 				     cn->v->v.str);
 
-	if (!(cn = find_config_node(sn, "metadata")) ||
-	    !cn->v || cn->v->type != CFG_STRING)
+	if (!(cn = dm_config_find_node(sn, "metadata")) ||
+	    !cn->v || cn->v->type != DM_CFG_STRING)
 		return SEG_LOG_ERROR("Thin pool metadata must be a string in");
 
 	if (!(seg->metadata_lv = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown pool metadata %s in",
 				     cn->v->v.str);
 
-	if (!get_config_uint64(sn, "transaction_id", &seg->transaction_id))
+	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
-	if (find_config_node(sn, "zero_new_blocks") &&
-	    !get_config_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
+	if (dm_config_find_node(sn, "zero_new_blocks") &&
+	    !dm_config_get_uint32(sn, "zero_new_blocks", &seg->zero_new_blocks))
 		return SEG_LOG_ERROR("Could not read zero_new_blocks for");
 
 	return 1;
@@ -90,21 +90,21 @@
 	return seg->segtype->name;
 }
 
-static int _thin_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _thin_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 			struct dm_hash_table *pv_hash __attribute__((unused)))
 {
-	const struct config_node *cn;
+	const struct dm_config_node *cn;
 
-	if (!(cn = find_config_node(sn, "thin_pool")) ||
-	    !cn->v || cn->v->type != CFG_STRING)
+	if (!(cn = dm_config_find_node(sn, "thin_pool")) ||
+	    !cn->v || cn->v->type != DM_CFG_STRING)
 		return SEG_LOG_ERROR("Thin pool must be a string in");
 
 	if (!(seg->thin_pool_lv = find_lv(seg->lv->vg, cn->v->v.str)))
 		return SEG_LOG_ERROR("Unknown thin pool %s in",
 				     cn->v->v.str);
 
-	if ((cn = find_config_node(sn, "origin"))) {
-                if (!cn->v || cn->v->type != CFG_STRING)
+	if ((cn = dm_config_find_node(sn, "origin"))) {
+                if (!cn->v || cn->v->type != DM_CFG_STRING)
 			return SEG_LOG_ERROR("Thin pool origin must be a string in");
 
 		if (!(seg->origin = find_lv(seg->lv->vg, cn->v->v.str)))
@@ -112,7 +112,7 @@
 					     cn->v->v.str);
 	}
 
-	if (!get_config_uint64(sn, "device_id", &seg->device_id))
+	if (!dm_config_get_uint64(sn, "device_id", &seg->device_id))
 		return SEG_LOG_ERROR("Could not read device_id for");
 
 	return 1;
--- LVM2/lib/unknown/unknown.c	2011/07/18 13:26:09	1.7
+++ LVM2/lib/unknown/unknown.c	2011/08/30 14:55:18	1.8
@@ -32,17 +32,17 @@
 	return seg->segtype->name;
 }
 
-static int _unknown_text_import(struct lv_segment *seg, const struct config_node *sn,
+static int _unknown_text_import(struct lv_segment *seg, const struct dm_config_node *sn,
 				struct dm_hash_table *pv_hash)
 {
-	struct config_node *new, *last = NULL, *head = NULL;
-	const struct config_node *current;
+	struct dm_config_node *new, *last = NULL, *head = NULL;
+	const struct dm_config_node *current;
 	log_verbose("importing unknown segment");
 	for (current = sn; current != NULL; current = current->sib) {
 		if (!strcmp(current->key, "type") || !strcmp(current->key, "start_extent") ||
 		    !strcmp(current->key, "tags") || !strcmp(current->key, "extent_count"))
 			continue;
-		new = clone_config_node_with_mem(seg->lv->vg->vgmem, current, 0);
+		new = dm_config_clone_node_with_mem(seg->lv->vg->vgmem, current, 0);
 		if (!new)
 			return_0;
 		if (last)
@@ -57,7 +57,7 @@
 
 static int _unknown_text_export(const struct lv_segment *seg, struct formatter *f)
 {
-	struct config_node *cn = seg->segtype_private;
+	struct dm_config_node *cn = seg->segtype_private;
 	return out_config_node(f, cn);
 }
 
--- LVM2/tools/dumpconfig.c	2009/11/03 15:50:43	1.9
+++ LVM2/tools/dumpconfig.c	2011/08/30 14:55:19	1.10
@@ -19,7 +19,7 @@
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
 
-	if (!write_config_file(cmd->cft, file, argc, argv)) {
+	if (!dm_config_write(cmd->cft, file, argc, argv)) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/tools/pvchange.c	2011/08/10 20:25:31	1.92
+++ LVM2/tools/pvchange.c	2011/08/30 14:55:19	1.93
@@ -209,7 +209,7 @@
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
-			unescape_colons_and_at_signs(pv_name, NULL, NULL);
+			dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
 			vg_name = find_vgname_from_pvname(cmd, pv_name);
 			if (!vg_name) {
 				log_error("Failed to read physical volume %s",
--- LVM2/tools/pvck.c	2010/09/23 12:02:34	1.5
+++ LVM2/tools/pvck.c	2011/08/30 14:55:19	1.6
@@ -31,7 +31,7 @@
 		/* FIXME: warning and/or check if in use? */
 		log_verbose("Scanning %s", argv[i]);
 
-		unescape_colons_and_at_signs(argv[i], NULL, NULL);
+		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 		pv_analyze(cmd, argv[i],
 			   arg_uint64_value(cmd, labelsector_ARG,
 					   UINT64_C(0)));
--- LVM2/tools/pvcreate.c	2011/08/10 20:25:31	1.96
+++ LVM2/tools/pvcreate.c	2011/08/30 14:55:19	1.97
@@ -110,7 +110,7 @@
 			return ECMD_FAILED;
 		}
 
-		unescape_colons_and_at_signs(argv[i], NULL, NULL);
+		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
 		if (!(pv = pvcreate_single(cmd, argv[i], &pp, 1))) {
 			stack;
--- LVM2/tools/pvmove.c	2011/08/10 20:25:31	1.85
+++ LVM2/tools/pvmove.c	2011/08/30 14:55:19	1.86
@@ -664,7 +664,7 @@
 			return ECMD_FAILED;
 		}
 
-		unescape_colons_and_at_signs(pv_name, &colon, NULL);
+		dm_unescape_colons_and_at_signs(pv_name, &colon, NULL);
 
 		/* Drop any PE lists from PV name */
 		if (colon)
--- LVM2/tools/pvremove.c	2011/06/01 19:29:34	1.35
+++ LVM2/tools/pvremove.c	2011/08/30 14:55:19	1.36
@@ -150,7 +150,7 @@
 	}
 
 	for (i = 0; i < argc; i++) {
-		unescape_colons_and_at_signs(argv[i], NULL, NULL);
+		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 		r = pvremove_single(cmd, argv[i], NULL);
 		if (r > ret)
 			ret = r;
--- LVM2/tools/toollib.c	2011/08/10 20:25:31	1.228
+++ LVM2/tools/toollib.c	2011/08/30 14:55:19	1.229
@@ -707,7 +707,7 @@
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
-			unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
+			dm_unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
 			if (at_sign && (at_sign == argv[opt])) {
 				tagname = at_sign + 1;
 
@@ -1129,7 +1129,7 @@
 	dm_list_init(&arg_pvnames);
 
 	for (i = 0; i < argc; i++) {
-		unescape_colons_and_at_signs(argv[i], &colon, &at_sign);
+		dm_unescape_colons_and_at_signs(argv[i], &colon, &at_sign);
 
 		if (at_sign && (at_sign == argv[i])) {
 			tagname = at_sign + 1;
--- LVM2/tools/vgsplit.c	2011/08/10 20:25:31	1.108
+++ LVM2/tools/vgsplit.c	2011/08/30 14:55:19	1.109
@@ -395,7 +395,7 @@
 
 	/* Move PVs across to new structure */
 	for (opt = 0; opt < argc; opt++) {
-		unescape_colons_and_at_signs(argv[opt], NULL, NULL);
+		dm_unescape_colons_and_at_signs(argv[opt], NULL, NULL);
 		if (!move_pv(vg_from, vg_to, argv[opt]))
 			goto_bad;
 	}


