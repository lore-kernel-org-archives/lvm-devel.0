From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 17 Aug 2015 19:54:24 +0000 (UTC)
Subject: master - config: explain automatic default values
Message-ID: <20150817195424.39C8B60B28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5243a81c29a4b60fe8ef8e12b9a1486a3f2b85a6
Commit:        5243a81c29a4b60fe8ef8e12b9a1486a3f2b85a6
Parent:        12acf852c5661b771d8800a60dcf1ac799466289
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 13 13:35:45 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 17 13:52:34 2015 -0500

config: explain automatic default values

Before printing a commented automatic config value,
print a line describing what it is.  Otherwise, the
commented value can look like it's a part of an
example preceding it.
---
 lib/config/config.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index d7a6cd9..bfcf87c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1717,6 +1717,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		if (cfg_def->flags & CFG_DEFAULT_UNDEFINED)
 			fprintf(out->fp, "%s# This configuration %s does not have a default value defined.\n", line, node_type_name);
 
+		if (cfg_def->flags & CFG_DEFAULT_COMMENTED)
+			fprintf(out->fp, "%s# This configuration %s has an automatic default value.\n", line, node_type_name);
+
 		if ((out->tree_spec->type == CFG_DEF_TREE_FULL) &&
 		    (out->tree_spec->check_status[cn->id] & CFG_USED))
 			fprintf(out->fp, "%s# Value defined in existing configuration has been used for this setting.\n", line);


