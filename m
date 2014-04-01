From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 18:56:11 +0000 (UTC)
Subject: master - cleanup: just rename for interal function
Message-ID: <20140401185611.A566C60CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1eaef2b705f82969e0a463f122ddda569676ce13
Commit:        1eaef2b705f82969e0a463f122ddda569676ce13
Parent:        9cb053339e5e001c57a2565f25b499ffb02d7f8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 20:08:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 20:54:09 2014 +0200

cleanup: just rename for interal function

---
 tools/lvchange.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 982e620..bddc079 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -933,7 +933,7 @@ static int lvchange_activation_skip(struct logical_volume *lv)
 }
 
 
-static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
+static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
@@ -1270,5 +1270,5 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	return process_each_lv(cmd, argc, argv,
 			       update ? READ_FOR_UPDATE : 0, NULL,
-			       &lvchange_single);
+			       &_lvchange_single);
 }


