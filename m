From: Thomas Bechtold <thomasbechtold@jpberlin.de>
Date: Tue, 10 Oct 2017 10:42:58 +0200
Subject: [PATCH] config: Enable hosttags by default
Message-ID: <20171010084258.4694-1-thomasbechtold@jpberlin.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Thomas Bechtold <tbechtold@suse.com>

There is currently no way to modify the lvm configuration on a
specific host without modifiying lvm.conf first due to the current
default config.
This is bad for configuration management systems (Chef, Salt, Ansible,
...) because changing the lvm configuration needs to modify lvm.conf
which overrides the distro default config then with a template
provided by the config-mgmt-system.
Enabling hosttags improves the situation because config-mgmt-systems
can simply drop a file in /etc/lvm/lvm_$(uname -n).conf without
modifying /etc/lvm/lvm.conf first.
---
 conf/example.conf.in       | 2 +-
 lib/commands/toolcontext.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b5b0e6af1..4dc89b51c 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -2092,7 +2092,7 @@ dmeventd {
 	# Create a host tag using the machine name.
 	# The machine name is nodename returned by uname(2).
 	# This configuration option has an automatic default value.
-	# hosttags = 0
+	# hosttags = 1
 
 	# Configuration section tags/<tag>.
 	# Replace this subsection name with a custom tag name.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 39b300a78..09c75862b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1863,7 +1863,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	cmd->handles_unknown_segments = 0;
 	cmd->independent_metadata_areas = 0;
 	cmd->ignore_clustered_vgs = 0;
-	cmd->hosttags = 0;
+	cmd->hosttags = 1;
 	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
@@ -2137,7 +2137,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	cmd->initialized.config = 0;
 
-	cmd->hosttags = 0;
+	cmd->hosttags = 1;
 
 	cmd->lib_dir = NULL;
 
-- 
2.14.2


