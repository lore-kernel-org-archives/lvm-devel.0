From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Jun 2013 11:48:05 +0000 (UTC)
Subject: master - cleanup: add dot to lvchange message
Message-ID: <20130625114805.A70DB61386@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d46588c2d7b051a69564bd862a5b2579c2cdb8f3
Commit:        d46588c2d7b051a69564bd862a5b2579c2cdb8f3
Parent:        da9263905c946914f0c18fc25fb0d4d34875fd1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 13:43:35 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: add dot to lvchange message

---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index d645da6..c88d8ef 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1054,7 +1054,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (doit)
-		log_print_unless_silent("Logical volume \"%s\" changed", lv->name);
+		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
 	if (arg_count(cmd, resync_ARG))
 		if (!lvchange_resync(cmd, lv)) {


