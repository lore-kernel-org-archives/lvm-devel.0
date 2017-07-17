From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:30 -0400
Subject: master - numbers: strtod or strtoul need reset of errno
Message-ID: <201707171140.v6HBeULp022536@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba9820b14223b731125c83dbc9709aa44fdcdbf1
Commit:        ba9820b14223b731125c83dbc9709aa44fdcdbf1
Parent:        94838b4df06c4f5a47c4cb51d5949d8e7b4684e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 10:28:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

numbers: strtod or strtoul need reset of errno

API for strtod() or strtoul() needs reset of errno, before it's being
called. So add missing resets in missing places and some also some
errno validation for out-of-range numbers.
---
 daemons/dmfilemapd/dmfilemapd.c     |   15 ++++++++++-----
 daemons/lvmlockd/lvmlockd-sanlock.c |    3 +++
 lib/config/config.c                 |    6 ++++--
 libdm/libdm-config.c                |   10 ++++++++++
 libdm/libdm-report.c                |    4 ++++
 libdm/libdm-stats.c                 |    9 ++++++---
 tools/dmsetup.c                     |    3 ++-
 tools/lvmcmdline.c                  |    6 +++++-
 8 files changed, 44 insertions(+), 12 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index a51187a..aa50242 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -225,8 +225,9 @@ static int _is_open(const char *path)
 	while ((proc_dp = readdir(proc_d)) != NULL) {
 		if (!isdigit(proc_dp->d_name[0]))
 			continue;
+		errno = 0;
 		pid = (pid_t) strtol(proc_dp->d_name, NULL, 10);
-		if (!pid)
+		if (errno || !pid)
 			continue;
 		if (_is_open_in_pid(pid, path)) {
 			if (closedir(proc_d))
@@ -278,8 +279,9 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 	fm->nr_regions = 1;
 
 	/* parse <fd> */
+	errno = 0;
 	fm->fd = (int) strtol(argv[0], &endptr, 10);
-	if (*endptr) {
+	if (errno || *endptr) {
 		_early_log("Could not parse file descriptor: %s", argv[0]);
 		return 0;
 	}
@@ -288,8 +290,9 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 	argv++;
 
 	/* parse <group_id> */
+	errno = 0;
 	fm->group_id = strtoull(argv[0], &endptr, 10);
-	if (*endptr) {
+	if (*endptr || errno) {
 		_early_log("Could not parse group identifier: %s", argv[0]);
 		return 0;
 	}
@@ -332,8 +335,9 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 
 	/* parse [<foreground>[<verbose>]] */
 	if (argc) {
+		errno = 0;
 		_foreground = (int) strtol(argv[0], &endptr, 10);
-		if (*endptr) {
+		if (errno || *endptr) {
 			_early_log("Could not parse debug argument: %s.",
 				   argv[0]);
 			return 0;
@@ -341,8 +345,9 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		argc--;
 		argv++;
 		if (argc) {
+			errno = 0;
 			_verbose = (int) strtol(argv[0], &endptr, 10);
-			if (*endptr) {
+			if (errno || *endptr) {
 				_early_log("Could not parse verbose "
 					   "argument: %s", argv[0]);
 				return 0;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index e344cb1..aedd506 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -224,7 +224,10 @@ static int lock_lv_offset_from_args(char *lv_args, uint64_t *lock_lv_offset)
 	if (rv < 0)
 		return rv;
 
+	errno = 0;
 	*lock_lv_offset = strtoull(offset_str, NULL, 10);
+	if (errno)
+		return -1;
 	return 0;
 }
 
diff --git a/lib/config/config.c b/lib/config/config.c
index c62b4c3..5c5916b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -742,14 +742,16 @@ static struct dm_config_value *_get_def_array_values(struct cmd_context *cmd,
 		switch (toupper(token[0])) {
 			case 'I':
 			case 'B':
+				errno = 0;
 				v->v.i = strtoll(token + 1, &r, 10);
-				if (*r)
+				if (errno || *r)
 					goto bad;
 				v->type = DM_CFG_INT;
 				break;
 			case 'F':
+				errno = 0;
 				v->v.f = strtod(token + 1, &r);
-				if (*r)
+				if (errno || *r)
 					goto bad;
 				v->type = DM_CFG_FLOAT;
 				break;
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 90e3405..d85effb 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -679,13 +679,23 @@ static struct dm_config_value *_type(struct parser *p)
 	switch (p->t) {
 	case TOK_INT:
 		v->type = DM_CFG_INT;
+		errno = 0;
 		v->v.i = strtoll(p->tb, NULL, 0);	/* FIXME: check error */
+		if (errno) {
+			log_error("Failed to read int token.");
+			return NULL;
+		}
 		match(TOK_INT);
 		break;
 
 	case TOK_FLOAT:
 		v->type = DM_CFG_FLOAT;
+		errno = 0;
 		v->v.f = strtod(p->tb, NULL);	/* FIXME: check error */
+		if (errno) {
+			log_error("Failed to read float token.");
+			return NULL;
+		}
 		match(TOK_FLOAT);
 		break;
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0017ac3..20a0827 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3185,6 +3185,7 @@ static const char *_tok_value_time(const struct dm_report_field_type *ft,
 			goto out;
 		}
 
+		errno = 0;
 		if (((t = strtoull(time_str, NULL, 10)) == ULLONG_MAX) && errno == ERANGE) {
 			log_error(_out_of_range_msg, time_str, ft->id);
 			goto out;
@@ -3555,6 +3556,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.i = (((const uint64_t *) rvw->value)[1]);
 				} else {
+					errno = 0;
 					if (((fs->value->v.i = strtoull(s, NULL, 10)) == ULLONG_MAX) &&
 						 (errno == ERANGE)) {
 						log_error(_out_of_range_msg, s, field_id);
@@ -3573,6 +3575,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.d = (((const double *) rvw->value)[1]);
 				} else {
+					errno = 0;
 					fs->value->v.d = strtod(s, NULL);
 					if (errno == ERANGE) {
 						log_error(_out_of_range_msg, s, field_id);
@@ -3594,6 +3597,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.i = (((const uint64_t *) rvw->value)[1]);
 				} else {
+					errno = 0;
 					fs->value->v.d = strtod(s, NULL);
 					if ((errno == ERANGE) || (fs->value->v.d < 0) || (fs->value->v.d > 100)) {
 						log_error(_out_of_range_msg, s, field_id);
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5cb7c2c..541823b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -853,8 +853,9 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 			val_start = c;
 			endptr = NULL;
 
+			errno = 0;
 			this_val = strtoull(val_start, &endptr, 10);
-			if (!endptr) {
+			if (errno || !endptr) {
 				log_error("Could not parse histogram boundary.");
 				goto bad;
 			}
@@ -1174,8 +1175,9 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 			val_start = c;
 			endptr = NULL;
 
+			errno = 0;
 			this_val = strtoull(val_start, &endptr, 10);
-			if (!endptr) {
+			if (errno || !endptr) {
 				log_error("Could not parse histogram value.");
 				goto bad;
 			}
@@ -1992,8 +1994,9 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	}
 
 	if (region_id) {
+		errno = 0;
 		*region_id = strtoull(resp, &endptr, 10);
-		if (resp == endptr)
+		if (errno || resp == endptr)
 			goto_out;
 	}
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5c5c14c..2eed39e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1270,8 +1270,9 @@ static int _message(CMD_ARGS)
 		argv++;
 	}
 
+	errno = 0;
 	sector = strtoull(argv[0], &endptr, 10);
-	if (*endptr || endptr == argv[0]) {
+	if (errno || *endptr || endptr == argv[0]) {
 		err("invalid sector");
 		goto out;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index d3523be..9cf2144 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -563,6 +563,7 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 	if (!isdigit(*val))
 		return 0;
 
+	errno = 0;
 	v = strtod(val, &ptr);
 
 	if (*ptr == '.') {
@@ -571,13 +572,16 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 		 * Lets be toleran and retry with standard C locales
 		 */
 		if (setlocale(LC_ALL, "C")) {
+			errno = 0;
 			v = strtod(val, &ptr);
 			setlocale(LC_ALL, "");
 		}
 	}
 
-	if (ptr == val)
+	if (ptr == val || errno) {
+		log_error("Can't parse size argument at '%c'.%s%s", ptr[0], (errno) ? " " :"", (errno) ? strerror(errno) : "");
 		return 0;
+	}
 
 	if (percent && *ptr == '%') {
 		if (!_get_percent_arg(av, ++ptr))


