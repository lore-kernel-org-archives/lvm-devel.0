From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 12:10:29 +0000 (UTC)
Subject: master - lvmconfig: comment out settings with proper space/tab prefix
Message-ID: <20150430121029.C612960F6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4388ab477c644c3d58b81acf2de969d49fb984ca
Commit:        4388ab477c644c3d58b81acf2de969d49fb984ca
Parent:        3706abde5e7703562bad3072cca13faf31b6b8b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 13:59:00 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 14:06:55 2015 +0200

lvmconfig: comment out settings with proper space/tab prefix

We're commenting out settings with undefined default values.
The comment character '#' was printed at the very beginning of
the line, it should be placed just at the beginning of the setting,
after the space/tab prefix is printed.

Before this patch:

  $ lvmconfig --type default activation
  activation {
           ...
  #        volume_list=[]
           ...
  }

With this patch applied:

  $ lvmconfig --type default activation
  activation {
           ...
           # volume_list=[]
           ...
  }
---
 lib/config/config.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 167cfff..385bf9e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1609,6 +1609,8 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	char summary[MAX_COMMENT_LINE+1];
 	char version[9];
 	int pos = 0;
+	size_t len;
+	char *space_prefix;
 
 	if ((out->tree_spec->type == CFG_DEF_TREE_DIFF) &&
 	    (!(out->tree_spec->check_status[cn->id] & CFG_DIFF)))
@@ -1639,9 +1641,15 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	}
 
 	/* Usual tree view with nodes and their values. */
-	fprintf(out->fp, "%s%s\n", (out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
-				   (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
-				   (cfg_def->flags & CFG_DEFAULT_UNDEFINED) ? "#" : "", line);
+	if ((out->tree_spec->type != CFG_DEF_TREE_CURRENT) &&
+	    (out->tree_spec->type != CFG_DEF_TREE_DIFF) &&
+	    (cfg_def->flags & CFG_DEFAULT_UNDEFINED)) {
+		space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
+		fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
+		if (space_prefix)
+			dm_pool_free(out->mem, space_prefix);
+	} else
+		fprintf(out->fp, "%s\n", line);
 
 	return 1;
 }


