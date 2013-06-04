From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:11 +0000 (UTC)
Subject: dev-mornfall-activate - clvmd: use pclose
Message-ID: <20130604192411.665B46119A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61d0ae7019aa14d78678a36f1eeb43b29a113e80
Commit:        61d0ae7019aa14d78678a36f1eeb43b29a113e80
Parent:        0125518d6d0a0fce63998fc898c203255ad73700
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 11:30:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:56:59 2013 +0200

clvmd: use pclose

For popened FILE use pclose.
---
 daemons/clvmd/lvm-functions.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 416d4f0..6d78090 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -772,8 +772,8 @@ static int get_initial_state(struct dm_hash_table *excl_uuid)
 			}
 		}
 	}
-	if (fclose(lvs))
-		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
+	if (pclose(lvs))
+		DEBUGLOG("lvs pclose failed: %s\n", strerror(errno));
 
 	dm_free(lvs_cmd);
 


