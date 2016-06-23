From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:03:22 +0000 (UTC)
Subject: master - lvresize: let pass even protected names like _tmeta
Message-ID: <20160623230322.8B444609D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c921f18e236055b2d6b20794be076124489d6ac
Commit:        7c921f18e236055b2d6b20794be076124489d6ac
Parent:        1bb7a155d169c3fc115533658206c242f43bdd0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 00:33:40 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 00:39:14 2016 +0200

lvresize: let pass even protected names like _tmeta

Only later validation can decide if the volume is actually restricted
from being resized  (unlike in lvcreate time).
---
 tools/lvresize.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 35b7044..28fd0fd 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -113,7 +113,7 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 
 	lp->lv_name = argv[0];
 
-	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name))
 		return_0;
 
 	/* Check for $LVM_VG_NAME */


