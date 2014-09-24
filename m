From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:56 +0000 (UTC)
Subject: master - vgchange: add sync point
Message-ID: <20140924085656.40A976109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b70bdc104991056a9e1c3f97c07b6f0ba3ae998
Commit:        5b70bdc104991056a9e1c3f97c07b6f0ba3ae998
Parent:        13c07c685ade35192348a6b60a6c19077976b089
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 23:22:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:47 2014 +0200

vgchange: add sync point

Before leaving _activate_lvs_in_vg() wait till devices
are active - so we do not print message about active
devices earlier then it really happens for a user.
---
 tools/vgchange.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index da0a05d..e817910 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -152,6 +152,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	sigint_restore();
+	sync_local_dev_names(vg->cmd);  /* Wait until devices are available */
 
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",


