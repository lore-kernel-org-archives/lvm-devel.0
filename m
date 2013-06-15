From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:19 +0000 (UTC)
Subject: master - mirror: add missing error message
Message-ID: <20130615221619.5EF5060D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8fb5f63637ca47ecffdf84c721ff21315df8ef42
Commit:        8fb5f63637ca47ecffdf84c721ff21315df8ef42
Parent:        54e062265074766becc06d2fdb0020ade56cf95d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 15 18:43:36 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:32 2013 +0200

mirror: add missing error message

When a user has not proceeded with conversion,
print the error message why the command has failed.
---
 lib/metadata/mirror.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6c6554e..4f36e0d 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1726,8 +1726,10 @@ int remove_mirror_log(struct cmd_context *cmd,
 				 "inactive mirror %s to core log. "
 				 "Proceed? [y/n]: ", lv->name) == 'y')
 		sync_percent = 0;
-	else
+	else {
+		log_error("Logical volume %s NOT converted.", lv->name);
 		return 0;
+	}
 
 	if (sync_percent == PERCENT_100)
 		init_mirror_in_sync(1);


