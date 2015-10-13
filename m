From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 20:12:09 +0000 (UTC)
Subject: master - dmeventd: fix missing '!'
Message-ID: <20151013201209.1B54060B2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f1a3b7090d421d46f245454bc5c8ed299a9cc1d
Commit:        3f1a3b7090d421d46f245454bc5c8ed299a9cc1d
Parent:        a91fbe9d27a79b4be7fad72fc7a1ba2a976ecd41
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 22:10:47 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 22:10:47 2015 +0200

dmeventd: fix missing '!'

During recent code changes '!' was badly converted.
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index aebe5f9..d5575f3 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -201,7 +201,7 @@ int register_device(const char *device,
 {
 	struct dso_state *state;
 
-	if (dmeventd_lvm2_init_with_pool("snapshot_state", state))
+	if (!dmeventd_lvm2_init_with_pool("snapshot_state", state))
 		goto_bad;
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvextend,


