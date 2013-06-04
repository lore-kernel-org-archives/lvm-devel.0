From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:15 +0000 (UTC)
Subject: dev-mornfall-activate - config: check for hash success
Message-ID: <20130604192415.8C5806119A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba3cee36300d56efcdcb0af883141b1b0a6129a1
Commit:        ba3cee36300d56efcdcb0af883141b1b0a6129a1
Parent:        5070ffbca7b16e4139b3da72bdff0c9add517351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 13:12:58 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:56:59 2013 +0200

config: check for hash success

Hash insert may fail.
---
 lib/config/config.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2c77f30..d1cf590 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -577,7 +577,11 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 				cmd->cft_def_hash = NULL;
 				r = 0; goto out;
 			}
-			dm_hash_insert(cmd->cft_def_hash, vp, def);
+			if (!dm_hash_insert(cmd->cft_def_hash, vp, def)) {
+				log_error("Failed to insert configuration to hash.");
+				r = 0;
+				goto out;
+			}
 		}
 	}
 


