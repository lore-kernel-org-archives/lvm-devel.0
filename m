From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 15:33:10 -0400
Subject: master - Remove code for loading other metadata formats
Message-ID: <201806131933.w5DJXAn2016894@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9df6f601e019d0e5b052d9e6aa0bd9dc732e411d
Commit:        9df6f601e019d0e5b052d9e6aa0bd9dc732e411d
Parent:        885e57cb2723b8f58e8bced534b81d536a1a16a4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 11:32:29 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 12:03:42 2018 -0500

Remove code for loading other metadata formats

other formats are not used.
---
 lib/commands/toolcontext.c |   70 ++++----------------------------------------
 1 files changed, 6 insertions(+), 64 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 20a73b7..aca93f9 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1331,73 +1331,21 @@ struct format_type *get_format_by_name(struct cmd_context *cmd, const char *form
         return NULL;
 }
 
+/* FIXME: there's only one format, get rid of the list of formats */
+
 static int _init_formats(struct cmd_context *cmd)
 {
-	const char *format;
-
 	struct format_type *fmt;
 
-#ifdef HAVE_LIBDL
-	const struct dm_config_node *cn;
-#endif
-
-#ifdef HAVE_LIBDL
-	/* Load any formats in shared libs if not static */
-	if (!is_static() &&
-	    (cn = find_config_tree_array(cmd, global_format_libraries_CFG, NULL))) {
-
-		const struct dm_config_value *cv;
-		struct format_type *(*init_format_fn) (struct cmd_context *);
-		void *lib;
-
-		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Invalid string in config file: "
-					  "global/format_libraries");
-				return 0;
-			}
-			if (!(lib = load_shared_library(cmd, cv->v.str,
-							"format", 0)))
-				return_0;
-
-			if (!(init_format_fn = dlsym(lib, "init_format"))) {
-				log_error("Shared library %s does not contain "
-					  "format functions", cv->v.str);
-				dlclose(lib);
-				return 0;
-			}
-
-			if (!(fmt = init_format_fn(cmd))) {
-				dlclose(lib);
-				return_0;
-			}
-
-			fmt->library = lib;
-			dm_list_add(&cmd->formats, &fmt->list);
-		}
-	}
-#endif
-
 	if (!(fmt = create_text_format(cmd)))
 		return 0;
-	fmt->library = NULL;
-	dm_list_add(&cmd->formats, &fmt->list);
 
+	dm_list_add(&cmd->formats, &fmt->list);
 	cmd->fmt_backup = fmt;
+	cmd->default_settings.fmt_name = fmt->name;
+	cmd->fmt = fmt;
 
-	format = find_config_tree_str(cmd, global_format_CFG, NULL);
-
-	dm_list_iterate_items(fmt, &cmd->formats) {
-		if (!strcasecmp(fmt->name, format) ||
-		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
-			cmd->default_settings.fmt_name = fmt->name;
-			cmd->fmt = fmt;
-			return 1;
-		}
-	}
-
-	log_error("_init_formats: Default format (%s) not found", format);
-	return 0;
+	return 1;
 }
 
 int init_lvmcache_orphans(struct cmd_context *cmd)
@@ -2014,17 +1962,11 @@ static void _destroy_formats(struct cmd_context *cmd, struct dm_list *formats)
 {
 	struct dm_list *fmtl, *tmp;
 	struct format_type *fmt;
-	void *lib;
 
 	dm_list_iterate_safe(fmtl, tmp, formats) {
 		fmt = dm_list_item(fmtl, struct format_type);
 		dm_list_del(&fmt->list);
-		lib = fmt->library;
 		fmt->ops->destroy(fmt);
-#ifdef HAVE_LIBDL
-		if (lib)
-			dlclose(lib);
-#endif
 	}
 
 	cmd->independent_metadata_areas = 0;


