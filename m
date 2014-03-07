From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  7 Mar 2014 17:04:11 +0000 (UTC)
Subject: master - config: keep config paths with variable names properly marked on output
Message-ID: <20140307170411.96CA161178@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfffccca948a526ad907c9d7d1b7de7850a48628
Commit:        bfffccca948a526ad907c9d7d1b7de7850a48628
Parent:        eeff7729d9a48b07bc650c552ec7a03b064c3bc9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 7 18:04:02 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 7 18:04:02 2014 +0100

config: keep config paths with variable names properly marked on output

---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 3c28321..38d3f0b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1118,7 +1118,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	cfg_def = cfg_def_get_item_p(cn->id);
 
 	if (out->tree_spec->withcomments) {
-		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 0);
+		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 1);
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
 
 		if (cfg_def->comment)


