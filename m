From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:21 +0000 (UTC)
Subject: master - cleanup: typo in message
Message-ID: <20140717142921.CB51C60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffa1a7b046b0ec62d478a848181f16c4ee0126bb
Commit:        ffa1a7b046b0ec62d478a848181f16c4ee0126bb
Parent:        ab72cdbf81ef5a52a63098b1997b3a6765a9edc5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 14:46:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:19:57 2014 +0200

cleanup: typo in message

in-release fix.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index eef408a..b630ee2 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -529,7 +529,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		;
 	else if (lp->snapshot) {	/* Snapshot creation from pre-existing cow */
 		if (!argc) {
-			log_error("Please provide logical volume path for snaphost origin.");
+			log_error("Please provide logical volume path for snapshot origin.");
 			return 0;
 		}
 		lp->origin_lv_name = argv[0];


