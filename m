From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:15:47 +0000 (UTC)
Subject: master - config: add comment note about advanced and unsupported config nodes
Message-ID: <20130306111547.2800AA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fd04bd93a1ea3e86c90c396151424719f3e1b63
Commit:        7fd04bd93a1ea3e86c90c396151424719f3e1b63
Parent:        088d88cfe27ba6f5f78812af778cde54d4aed9c1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 6 09:31:15 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 10:46:36 2013 +0100

config: add comment note about advanced and unsupported config nodes

This shows up in the output as a short commentary:

  $ lvm dumpconfig --type default --withcomments metadata/disk_areas
  # Configuration option metadata/disk_areas.
  # This configuration option is advanced.
  # This configuration option is not officially supported.
  disk_areas=""
---
 lib/config/config.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index e8e0379..1960b00 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -838,6 +838,12 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 		if (cfg_def->comment)
 			fprintf(out->fp, "%s# %s\n", line, cfg_def->comment);
+
+		if (cfg_def->flags & CFG_ADVANCED)
+			fprintf(out->fp, "%s# This configuration %s is advanced.\n", line, node_type_name);
+
+		if (cfg_def->flags & CFG_UNSUPPORTED)
+			fprintf(out->fp, "%s# This configuration %s is not officially supported.\n", line, node_type_name);
 	}
 
 	if (out->withversion) {


