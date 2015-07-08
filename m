From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  8 Jul 2015 20:27:35 +0000 (UTC)
Subject: master - vgchange: don't disable VG lock in lock_stop
Message-ID: <20150708202735.6DF0960DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0cc570f86ad267e4903aac9bedaecaf22e8d714
Commit:        a0cc570f86ad267e4903aac9bedaecaf22e8d714
Parent:        903569d53375f8305bcfb8c2a0e9af7c29fa1d46
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 8 15:14:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 8 15:26:25 2015 -0500

vgchange: don't disable VG lock in lock_stop

It was an optimization to avoid a pointless unlock call.
It affects all VGs, but was only intended to affect the
VG being stopped.
---
 tools/vgchange.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 92c854b..437dbae 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -873,8 +873,6 @@ do_start:
 
 static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
 {
-	/* Disable the unlock in toollib because it's pointless after the stop. */
-	cmd->lockd_vg_disable = 1;
 	return lockd_stop_vg(cmd, vg);
 }
 


