From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 13 Feb 2014 09:51:52 +0000 (UTC)
Subject: master - Fix premature return from get_pool_params
Message-ID: <20140213095152.A916660E05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a060b3b39088d81a8b5d419ae8e2444aa9b9d8ec
Commit:        a060b3b39088d81a8b5d419ae8e2444aa9b9d8ec
Parent:        e8225b86158cb3ea8edc678327a2c33543a73c01
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Feb 13 10:49:34 2014 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 13 10:50:56 2014 +0100

Fix premature return from get_pool_params

---
 tools/toollib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3dc76b8..7deb3a4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1673,7 +1673,6 @@ int get_pool_params(struct cmd_context *cmd,
 				  " converting to pool LVs.");
 			return_0;
 		}
-		return 1;
 	}
 
 	*passed_args = 0;


