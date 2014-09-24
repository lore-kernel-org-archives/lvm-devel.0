From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:29 +0000 (UTC)
Subject: master - debug: add missing stack trace
Message-ID: <20140924085729.B396060E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4319e06a0fe0b27471ea47687e344b836577f465
Commit:        4319e06a0fe0b27471ea47687e344b836577f465
Parent:        7531a9169e9b9fdb740dbd7c805ade55fb3a440c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 11:48:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

debug: add missing stack trace

---
 tools/vgchange.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index ba66b0f..dfb1251 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -234,8 +234,10 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 
-	if (!_activate_lvs_in_vg(cmd, vg, activate))
+	if (!_activate_lvs_in_vg(cmd, vg, activate)) {
+		stack;
 		r = 0;
+	}
 
 	/* Print message only if there was not found a missing VG */
 	if (!vg->cmd_missing_vgs)


