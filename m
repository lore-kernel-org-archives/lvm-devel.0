From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  4 Sep 2015 14:54:42 +0000 (UTC)
Subject: master - vgchange: improve error message about changing lock type
Message-ID: <20150904145442.46BF960100@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96948540825d8b3f8e89cbf22527a2d3d8435667
Commit:        96948540825d8b3f8e89cbf22527a2d3d8435667
Parent:        cdca2782d2b43c20d552d64359ac0ce80d24af5f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 4 09:53:33 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 4 09:53:33 2015 -0500

vgchange: improve error message about changing lock type

---
 tools/vgchange.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 6d86051..1d3c64a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -574,8 +574,10 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 	}
 
 	if (is_lockd_type(vg->lock_type) && is_lockd_type(lock_type)) {
-		log_error("First change from lock type %s to none, then to lock type %s",
+		log_error("Cannot change lock type directly from \"%s\" to \"%s\".",
 			  vg->lock_type, lock_type);
+		log_error("First change lock type to \"none\", then to \"%s\".",
+			  lock_type);
 		return 0;
 	}
 


