From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 16 Apr 2013 08:45:53 +0000 (UTC)
Subject: master - config_def_check: fix memory leak
Message-ID: <20130416084553.B08EC1CC9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ccb9eb861c3b65ffc1aac024425e2cc10950077
Commit:        2ccb9eb861c3b65ffc1aac024425e2cc10950077
Parent:        2e0740f7ef420c7b981bc67cb606d180701b8c1d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Apr 16 10:42:03 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 16 10:45:37 2013 +0200

config_def_check: fix memory leak

There is no need to strdup a key when inserting into
the hash table as the table allocates memory and copies
the string.  This was causing memory to be lost.
---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 009eb5f..2c77f30 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -577,7 +577,7 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 				cmd->cft_def_hash = NULL;
 				r = 0; goto out;
 			}
-			dm_hash_insert(cmd->cft_def_hash, dm_strdup(vp), def);
+			dm_hash_insert(cmd->cft_def_hash, vp, def);
 		}
 	}
 


