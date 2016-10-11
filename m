From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:32 +0000 (UTC)
Subject: master - cleanup: lvconvert drop unused variable
Message-ID: <20161011113932.4F0CC61152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f576483a87aac67037e25914990a77e76c81423
Commit:        6f576483a87aac67037e25914990a77e76c81423
Parent:        c8b6c130158e1cc1a639afc21f5fd6306286fdb3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 11:52:07 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:37:43 2016 +0200

cleanup: lvconvert drop unused variable

---
 tools/lvconvert.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 161062d..78cd7de 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -50,8 +50,6 @@ struct lvconvert_params {
 	int splitsnapshot;
 	int thin;
 	int uncache;
-	int other_conversion;	/* Everything else */
-
 	int corelog;		/* Equivalent to --mirrorlog core */
 	int mirrorlog;		/* Only one of corelog and mirrorlog may be set */
 
@@ -644,8 +642,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 	    lp->cache + lp->thin + lp->keep_mimages + lp->snapshot + lp->replace + lp->repair > 1) {
 		log_error(INTERNAL_ERROR "Unexpected combination of incompatible options selected.");
 		return 0;
-	} else
-		lp->other_conversion = 1;
+	}
 
 	/*
 	 * Final checking of each case:


