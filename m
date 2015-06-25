From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Jun 2015 11:55:11 +0000 (UTC)
Subject: master - lvmconfig: do not display settings with undefined default values
Message-ID: <20150625115511.4457C60FDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=844707067b5aef9bbcdf169b66a25bb79690d325
Commit:        844707067b5aef9bbcdf169b66a25bb79690d325
Parent:        07a34184dba585a4de875035e2acecc9dab1862d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 25 12:49:59 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 25 13:51:55 2015 +0200

lvmconfig: do not display settings with undefined default values

Do not display settings with undefined default values, but do display
these settings in case the value is defined directly in any part of
the existing config cascade.

For example, the lvmconfig --type current always displays these settings
(as it's somewhere in "current" configuration cascade that makes it defined).
The lvmconfig --type full displays these settings only if it's defined
somewhere in the cascade, but not if default value is used instead
The lvmconfig --type default never displays these settings...

More concrete example - let's have activation/volume_list directly
set in lvm.conf and activation/read_only_volume_list not set.
Both of these settings have *undefined default* values.

  $lvmconfig --type full activation/volume_list activation/read_only_volume_list
  volume_list="/dev/vg/lv"

(...only volume_list is defined, hence it's printed)

However, the comments will display more info (see also previous commit):

  $lvmconfig --type full activation/volume_list activation/read_only_volume_list --withsummary

  # Configuration option activation/volume_list.
  # Only LVs selected by this list are activated.
  # This configuration option does not have a default value defined.
  # Value defined in existing configuration has been used for this setting.
  volume_list="/dev/vg/lv"

  # Configuration option activation/read_only_volume_list.
  # LVs in this list are activated in read-only mode.
  # This configuration option does not have a default value defined.
---
 lib/config/config.c |   28 +++++++++++++++++++++++-----
 1 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 4ce97a9..53987f8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1629,6 +1629,16 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	return 1;
 }
 
+static int _should_print_cfg_with_undef_def_val(struct out_baton *out, cfg_def_item_t *cfg_def,
+						const struct dm_config_node *cn)
+{
+	if (!(cfg_def->flags & CFG_DEFAULT_UNDEFINED))
+		return 1;
+
+	/* print it only if the value is directly defined in some config = it's used */
+	return out->tree_spec->check_status && (out->tree_spec->check_status[cn->id] & CFG_USED);
+}
+
 static int _out_line_fn(const struct dm_config_node *cn, const char *line, void *baton)
 {
 	struct out_baton *out = baton;
@@ -1671,15 +1681,23 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	}
 
 	/* Usual tree view with nodes and their values. */
+
 	if ((out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
 	    (out->tree_spec->type != CFG_DEF_TREE_FULL) &&
 	    (cfg_def->flags & (CFG_DEFAULT_UNDEFINED | CFG_DEFAULT_COMMENTED))) {
-		space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
-		fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
-		if (space_prefix)
-			dm_pool_free(out->mem, space_prefix);
-	} else
+		/* print with # at the front to comment out the line */
+		if (_should_print_cfg_with_undef_def_val(out, cfg_def, cn)) {
+			space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
+			fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
+			if (space_prefix)
+				dm_pool_free(out->mem, space_prefix);
+		}
+		return 1;
+	}
+
+	/* print the line as it is */
+	if (_should_print_cfg_with_undef_def_val(out, cfg_def, cn))
 		fprintf(out->fp, "%s\n", line);
 
 	return 1;


