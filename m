From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:43 -0500
Subject: master - Revert "cov: check for retvalue"
Message-ID: <69996.119112712203700850@us-mta-405.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=595aa1d4526185e0fe52430ce019a07103014b0c
Commit:        595aa1d4526185e0fe52430ce019a07103014b0c
Parent:        98a8099da9e43561a1fe981bbf2866e373f0d07a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:31:27 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:09 2019 -0600

Revert "cov: check for retvalue"

This reverts commit 153e55c20e9a3810a1862314a6465179e1b53931.

fixes folded into subsequent pvck commit
---
 tools/pvck.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 4a267dd..9f030c1 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -359,10 +359,7 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 			continue;
 		}
 
-		if (sscanf(line, "seqno = %u", &seqno) != 1) {
-			log_warn("WARNING: Failed to parse seqno.");
-			seqno = 0; /* Skip? */
-		}
+		sscanf(line, "seqno = %u", &seqno);
 
 		/*
 		 * The first three lines look like metadata with



