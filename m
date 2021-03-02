From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Mar 2021 20:15:46 +0000 (GMT)
Subject: main - lvmconfig: fix deprecation message
Message-ID: <20210302201546.B918B3950402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db4af67b37b224171d9b2fed21f144a5e8a82496
Commit:        db4af67b37b224171d9b2fed21f144a5e8a82496
Parent:        aa34da6eccb4dafe0a35129ddfb8ad7fb63fb7d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 2 13:49:41 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 2 14:14:28 2021 -0600

lvmconfig: fix deprecation message

When lvmconfig --typeconfig full printed a deprecated
entry it would attempt to print a non-existing
deprecation comment resulting in output like:
  # (null)        # This setting is no longer used.
---
 lib/config/config.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 96f2ad58d..9725dece3 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1708,6 +1708,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	const char *node_type_name = cn->v ? "option" : "section";
 	char path[CFG_PATH_MAX_LEN];
 	char commentline[MAX_COMMENT_LINE+1];
+	int is_deprecated = 0;
 
 	if (cn->id <= 0)
 		return 1;
@@ -1721,13 +1722,14 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 	cfg_def = cfg_def_get_item_p(cn->id);
 
+	is_deprecated = _def_node_is_deprecated(cfg_def, out->tree_spec);
+
 	if (out->tree_spec->withsummary || out->tree_spec->withcomments) {
 		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 1);
 		fprintf(out->fp, "\n");
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
-		if (out->tree_spec->withcomments &&
-		    _def_node_is_deprecated(cfg_def, out->tree_spec))
+		if (out->tree_spec->withcomments && is_deprecated && cfg_def->deprecation_comment)
 			fprintf(out->fp, "%s# %s", line, cfg_def->deprecation_comment);
 
 		if (cfg_def->comment) {
@@ -1745,7 +1747,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 			}
 		}
 
-		if (_def_node_is_deprecated(cfg_def, out->tree_spec))
+		if (is_deprecated)
 			fprintf(out->fp, "%s# This configuration %s is deprecated.\n", line, node_type_name);
 
 		if (cfg_def->flags & CFG_ADVANCED)
@@ -1773,7 +1775,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 			return_0;
 		fprintf(out->fp, "%s# Available since version %s.\n", line, version);
 
-		if (_def_node_is_deprecated(cfg_def, out->tree_spec)) {
+		if (is_deprecated) {
 			if (!_get_config_node_version(cfg_def->deprecated_since_version, version))
 				return_0;
 			fprintf(out->fp, "%s# Deprecated since version %s.\n", line, version);


