From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:21 +0000 (UTC)
Subject: master - config: skip close of stdin
Message-ID: <20130615221621.773EB60D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a040dd8cfb8828e07a4df00117d89173562ab8be
Commit:        a040dd8cfb8828e07a4df00117d89173562ab8be
Parent:        8fb5f63637ca47ecffdf84c721ff21315df8ef42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 23:18:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:32 2013 +0200

config: skip close of stdin

If the used stream has been stdout, do not close it.
---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2fd8793..cda9b83 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -916,7 +916,7 @@ int config_write(struct dm_config_tree *cft,
 		argv++;
 	}
 
-	if (baton.fp && dm_fclose(baton.fp)) {
+	if (baton.fp && baton.fp != stdout && dm_fclose(baton.fp)) {
 		stack;
 		r = 0;
 	}


