From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Jun 2016 21:52:33 +0000 (UTC)
Subject: master - pvscan: fix lvmlockd global lock
Message-ID: <20160615215233.81EE360DFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=944ae4d2df0f15afb29ac0a68d0dd012d9df9acf
Commit:        944ae4d2df0f15afb29ac0a68d0dd012d9df9acf
Parent:        15da467b52465076a8d587b94cc638bab8a0a95c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 15 16:51:36 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 15 16:51:36 2016 -0500

pvscan: fix lvmlockd global lock

This should have been removed when pvscan was
recently converted to use process_each_pv which
does the lvmlockd locking.
---
 tools/pvscan.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5987e8b..78dad82 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -624,10 +624,6 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	/* Needed for a current listing of the global VG namespace. */
-	if (!lockd_gl(cmd, "sh", 0))
-		return_ECMD_FAILED;
-
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;


