From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 17 Aug 2022 08:48:15 +0000 (GMT)
Subject: main - config: remove unnecessary copy of config line's space prefix before printing
Message-ID: <20220817084815.6AE083858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a23683a59835d967eff193bf1f82cc4ee5a6fdf
Commit:        8a23683a59835d967eff193bf1f82cc4ee5a6fdf
Parent:        b4cc28c2ef72ee022c1a03819927e31775c18676
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 17 10:11:05 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 17 10:47:43 2022 +0200

config: remove unnecessary copy of config line's space prefix before printing

When we wanted to insert '#' before a config line (to comment it out),
we used dm_pool_strndup to temporarily copy the space prefix first so
we can assemble the final line with:

   "<space_prefix># <key>=<value>":

out of original:

  "<space_prefix><key>=<value>".

The space_prefix copy is not necessary, we can just use fprintf's
precision modifier "%.*s" to print the exact part if we alrady
know space_prefix length.
---
 lib/config/config.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1142ed345..db8f3c2c1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1831,7 +1831,6 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	char version[9];
 	int pos = 0;
 	int space_prefix_len;
-	char *space_prefix;
 	const char *p;
 	size_t len;
 
@@ -1888,10 +1887,9 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	    (cfg_def->flags & (CFG_DEFAULT_UNDEFINED | CFG_DEFAULT_COMMENTED))) {
 		/* print with # at the front to comment out the line */
 		if (_should_print_cfg_with_undef_def_val(out, cfg_def, cn)) {
-			space_prefix = ((len = strspn(line, "\t "))) ? dm_pool_strndup(out->mem, line, len) : NULL;
-			fprintf(out->fp, "%s%s%s\n", space_prefix ? : "", "# ", line + len);
-			if (space_prefix)
-				dm_pool_free(out->mem, space_prefix);
+			space_prefix_len = strspn(line, "\t ");
+			fprintf(out->fp, "%.*s%s%s\n", space_prefix_len, line, "# ",
+				line + space_prefix_len);
 		}
 		return 1;
 	}

