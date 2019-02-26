From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Feb 2019 11:31:55 -0500
Subject: master - pvscan: fix hint recreation
Message-ID: <201902261631.x1QGVtJ4021890@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74460f70efca7c8ed76e5980b300668a1a328cc4
Commit:        74460f70efca7c8ed76e5980b300668a1a328cc4
Parent:        9aea6ae956543995b30282c984af5fdad2347f07
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 26 10:30:11 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 26 10:30:11 2019 -0600

pvscan: fix hint recreation

Restore part of the fix from f0089472e7 that was lost
in the process of backporting 74a388cca1.
---
 tools/pvscan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index c6f2902..389aafa 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -891,6 +891,9 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		_online_files_remove(_vgs_online_dir);
 		_online_pvscan_all_devs(cmd, complete_vgnames, NULL);
 		_unlock_online();
+
+		cmd->pvscan_recreate_hints = 0;
+		cmd->use_hints = 0;
 		goto activate;
 	}
 


