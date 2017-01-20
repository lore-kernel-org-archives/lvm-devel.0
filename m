From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:24 +0000 (UTC)
Subject: master - dmeventd_thin: enable support for external command
Message-ID: <20170120230424.6571660DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85dab3963fbf8b3cc1be84f2d7c43257075ac2a3
Commit:        85dab3963fbf8b3cc1be84f2d7c43257075ac2a3
Parent:        8c4f3633ac460f24342a83e98afa6e8186d453a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 22:54:20 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 00:01:05 2017 +0100

dmeventd_thin: enable support for external command

With this commit we start to support configurable action
from thin-pool monitoring via  'dmeventd/thin_command'
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a8d4105..4903de3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Support configurable command executed from dmeventd thin plugin.
   Support new R|r human readable units output format.
   Thin dmeventd plugin reacts faster on lvextend failure path with umount.
   Add dm_stats_bind_from_fd() to bind a stats handle from a file descriptor.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 2367bde..a676de3 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -357,8 +357,7 @@ int register_device(const char *device,
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_str,
 				   sizeof(state->cmd_str),
-				   "lvextend --use-policies",
-				   device)) {
+				   "_dmeventd_thin_command", device)) {
 		dmeventd_lvm2_exit_with_pool(state);
 		goto_bad;
 	}


