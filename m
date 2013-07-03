From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Jul 2013 12:48:55 +0000 (UTC)
Subject: master - lvconvert: use proper error path
Message-ID: <20130703124855.3E55360FAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eeb164b50f9e5e5ce39f7851fced7c29e1fc0202
Commit:        eeb164b50f9e5e5ce39f7851fced7c29e1fc0202
Parent:        fe09d84668487f2a6b64edccced1ed049cc9ac18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 2 23:59:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 3 14:44:51 2013 +0200

lvconvert: use proper error path

VG needs to be released in this error path
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4d2a432..ccc8420 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2413,7 +2413,7 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 			     &lp->passed_args, &lp->chunk_size,
 			     &lp->discards, &lp->poolmetadata_size,
 			     &lp->zero))
-		goto_out;
+		goto_bad;
 
 	/*
 	 * lp->pvh holds the list of PVs available for allocation or removal


