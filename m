From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 12:21:43 +0000 (UTC)
Subject: master - lvmconfig: allow --withversions alone with --type list
Message-ID: <20150430122143.F130160E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2c2718c11dc834a79a76acf34d76902daac5752
Commit:        d2c2718c11dc834a79a76acf34d76902daac5752
Parent:        4388ab477c644c3d58b81acf2de969d49fb984ca
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 14:18:14 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 14:18:14 2015 +0200

lvmconfig: allow --withversions alone with --type list

Before this patch:

$ lvmconfig --type list --withversions --withsummary global/use_lvmetad
global/use_lvmetad - Use lvmetad to cache metadata and reduce disk scanning. [2.2.93]

$ lvmconfig --type list --withversions global/use_lvmetad
global/use_lvmetad

With this patch applied:

$ lvmconfig --type list --withversions --withsummary global/use_lvmetad
global/use_lvmetad - Use lvmetad to cache metadata and reduce disk scanning. [2.2.93]

$ lvmconfig --type list --withversions global/use_lvmetad
global/use_lvmetad - [2.2.93]
---
 lib/config/config.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 385bf9e..bab7f8b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1624,18 +1624,20 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 			return 1;
 		if (!_cfg_def_make_path(config_path, CFG_PATH_MAX_LEN, cfg_def->id, cfg_def, 1))
 			return_0;
-		if (out->tree_spec->withsummary) {
-			summary[0] = '\0';
-			if (cfg_def->comment)
-				_copy_one_line(cfg_def->comment, summary, &pos, strlen(cfg_def->comment));
-			if (out->tree_spec->withversions && !_get_config_node_version(version, cfg_def))
-				return_0;
-			fprintf(out->fp, "%s - %s%s%s%s\n", config_path, summary,
-				out->tree_spec->withversions ? " [" : "",
-				out->tree_spec->withversions ? version : "",
-				out->tree_spec->withversions ? "]" : "");
-		} else
-			fprintf(out->fp, "%s\n", config_path);
+		if (out->tree_spec->withversions && !_get_config_node_version(version, cfg_def))
+			return_0;
+
+		summary[0] = '\0';
+		if (out->tree_spec->withsummary && cfg_def->comment)
+			_copy_one_line(cfg_def->comment, summary, &pos, strlen(cfg_def->comment));
+
+		fprintf(out->fp, "%s%s%s%s%s%s%s\n", config_path,
+			*summary || out->tree_spec->withversions ? " - ": "",
+			*summary ? summary : "",
+			*summary ? " " : "",
+			out->tree_spec->withversions ? "[" : "",
+			out->tree_spec->withversions ? version : "",
+			out->tree_spec->withversions ? "]" : "");
 
 		return 1;
 	}


