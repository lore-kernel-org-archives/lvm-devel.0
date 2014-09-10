From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:46 +0000 (UTC)
Subject: master - debug: turn message into debug
Message-ID: <20140910200546.13C2F611FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a5eb1bc38b8555d7ae0d16fa07db96a3b73db16
Commit:        3a5eb1bc38b8555d7ae0d16fa07db96a3b73db16
Parent:        a3b75d7a8a3caa832af3b7d1f7d3fa488901ae06
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 10 10:10:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 22:00:51 2014 +0200

debug: turn message into debug

This message should be printed only for activation commands,
however since the handling of this flag is not correct
(rhbz 1140029) and will require further changes,
do now just a minor change and switch message into log_debug
(so it's not printed i.e. with every  'lvs -v')
---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 10dac8f..14ea7a6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1343,7 +1343,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto_out;
 	_apply_settings(cmd);
 	if (cmd->degraded_activation)
-		log_verbose("DEGRADED MODE. Incomplete RAID LVs will be processed.");
+		log_debug("DEGRADED MODE. Incomplete RAID LVs will be processed.");
 
 	if (!get_activation_monitoring_mode(cmd, &monitoring))
 		goto_out;


