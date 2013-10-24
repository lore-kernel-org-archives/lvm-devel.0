From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 24 Oct 2013 16:19:05 +0000 (UTC)
Subject: master - clvmd: fix verify message rejection of REMOTE flag
Message-ID: <20131024161905.CD6D160C27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c0db84948ad616930e217f20768a4285ca67c5a
Commit:        4c0db84948ad616930e217f20768a4285ca67c5a
Parent:        c9c23d414802ed07c7638ce13d33dba3a629e887
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 11:10:09 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 11:18:22 2013 -0500

clvmd: fix verify message rejection of REMOTE flag

This fixes a bug in commit 19baf842 where verify_message
was rejecting the CLVMD_FLAG_REMOTE flag.  It was missed
since the patch was ported from an lvm version where that
flag does not exist.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index bed8e68..d57c0fd 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1124,7 +1124,7 @@ static int verify_message(char *buf, int len)
 
 	/* TODO: we may be able to narrow len/flags/clientid/arglen checks based on cmd */
 
-	if (h->flags & ~(CLVMD_FLAG_LOCAL | CLVMD_FLAG_SYSTEMLV | CLVMD_FLAG_NODEERRS)) {
+	if (h->flags & ~(CLVMD_FLAG_LOCAL | CLVMD_FLAG_SYSTEMLV | CLVMD_FLAG_NODEERRS | CLVMD_FLAG_REMOTE)) {
 		log_error("verify_message bad flags %x", h->flags);
 		return -1;
 	}


