From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:25 -0400
Subject: master - dmsetup: loop output table as verbose
Message-ID: <201803151004.w2FA4PeI023586@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c925692f58912fbe088a09cdbbc75bfa9e865f5
Commit:        4c925692f58912fbe088a09cdbbc75bfa9e865f5
Parent:        70ad633638b15568d53312afdfca699f85a26fd1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 21:02:32 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:50:30 2018 +0100

dmsetup: loop output table as verbose

Resulting loop table line was streamed to 'stderr' stream - assuming this
was not a feature when user used '-v' for more verbose output
and properly show it via  'log_verbose()' on 'stdout'.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index eac3bb6..64a45a6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6606,7 +6606,7 @@ static int _loop_table(char *table, size_t tlen, char *file,
 		return_0;
 
 	if (_switches[VERBOSE_ARG] > 1)
-		log_error("Table: %s", table);
+		log_verbose("Table: %s", table);
 
 	return 1;
 


