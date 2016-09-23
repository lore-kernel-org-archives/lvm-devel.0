From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 23 Sep 2016 13:02:34 +0000 (UTC)
Subject: master - toolcontext: read all configuration sources when checking config values in lvm2-activation-generator through lighweight toolcontext handler
Message-ID: <20160923130234.140AC60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5e093624dc9bc9644903442e59bf049aeaaa3ba
Commit:        b5e093624dc9bc9644903442e59bf049aeaaa3ba
Parent:        dbcfd59714bddb3162d97575e66e000d2d83acb6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 23 14:51:15 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 23 14:57:44 2016 +0200

toolcontext: read all configuration sources when checking config values in lvm2-activation-generator through lighweight toolcontext handler

We added lightweight toolcontext handle to avoid useless initialization
of some parts of the context and also to avoid problems when using the
handle very soon at system boot, like in lvm2-activation-generator
through lvm2app interface. However, we missed reading all the other
config sources like lvmlocal.conf as well as any tag config - we need to
read these too to get the final config value which may be overriden in
any of these additional config sources.

Currently, we use this lightweight toolcontext handle to read
global/use_lvmetad and global/use_lvmpolld config values in
lvm2-activation-generator using lvm2app interface (lvm_config_find_bool
lvm2app function).
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a178e6..d3953ff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvm2-activation-generator to read all LVM2 config sources. (2.02.155)
   Fix lvchange-rebuild-raid.sh to cope with older target versions.
   Use dm_config_parse_without_dup_node_check() to speedup metadata reading.
   Fix lvconvert --repair regression
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index eaabf98..c416575 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1787,10 +1787,27 @@ struct cmd_context *create_config_context(void)
 		goto_out;
 
 	dm_list_init(&cmd->config_files);
+	dm_list_init(&cmd->tags);
 
 	if (!_init_lvm_conf(cmd))
 		goto_out;
 
+	if (!_init_hostname(cmd))
+		goto_out;
+
+	if (!_init_tags(cmd, cmd->cft))
+		goto_out;
+
+	/* Load lvmlocal.conf */
+	if (*cmd->system_dir && !_load_config_file(cmd, "", 1))
+		goto_out;
+
+	if (!_init_tag_configs(cmd))
+		goto_out;
+
+	if (!(cmd->cft = _merge_config_files(cmd, cmd->cft)))
+		goto_out;
+
 	return cmd;
 out:
 	if (cmd)


