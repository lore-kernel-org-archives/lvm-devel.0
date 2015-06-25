From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Jun 2015 11:55:09 +0000 (UTC)
Subject: master - lvmconfig: display comment about value from existing config being used
Message-ID: <20150625115509.3354060FDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07a34184dba585a4de875035e2acecc9dab1862d
Commit:        07a34184dba585a4de875035e2acecc9dab1862d
Parent:        c794c163b5800625a116ee53711f4d8db786ff30
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 25 13:03:31 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 25 13:51:54 2015 +0200

lvmconfig: display comment about value from existing config being used

Display comment abour value from existing config being used. For example:

$ lvmconfig --type full --withsummary report/compact_output report/buffered

 # Configuration option report/compact_output.
 # Do not print empty report fields.
 # Value defined in existing configuration has been used for this setting.
 compact_output=1

 # Configuration option report/buffered.
 # Buffer report output.
 buffered=1
---
 lib/config/config.c |    4 ++++
 man/lvmconfig.8.in  |    5 ++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index fffaace..4ce97a9 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1608,6 +1608,10 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 
 		if (cfg_def->flags & CFG_DEFAULT_UNDEFINED)
 			fprintf(out->fp, "%s# This configuration %s does not have a default value defined.\n", line, node_type_name);
+
+		if ((out->tree_spec->type == CFG_DEF_TREE_FULL) &&
+		    (out->tree_spec->check_status[cn->id] & CFG_USED))
+			fprintf(out->fp, "%s# Value defined in existing configuration has been used for this setting.\n", line);
 	}
 
 	if (out->tree_spec->withversions) {
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index 6d1b3fc..bbbeb6d 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -72,7 +72,10 @@ Display full configuration tree - a combination of current configuration tree
 (\fB\-\-type current\fP) and tree of settings for which default values are
 used (\fB\-\-type missing\fP). This is exactly the configuration tree that
 LVM2 uses during command execution. Using this type also implies
-the use of \fB\-\-mergedconfig\fP option.
+the use of \fB\-\-mergedconfig\fP option. If comments are displayed
+(see \fB\-\-withcomments\fP and \fB\-\-withsummary\fP options), then
+for each setting found in existing configuration and for which defaults
+are not used, there's an extra comment line printed to denote this.
 .IP list 3
 Display plain list of configuration settings.
 .IP missing 3


