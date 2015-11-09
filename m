From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:22 +0000 (UTC)
Subject: master - lvconvert: add extra check for existance of pointer
Message-ID: <20151109092822.9C63A60DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18fd0bd20ce1d4a7d2bd27b2c9981a402f9bcd2e
Commit:        18fd0bd20ce1d4a7d2bd27b2c9981a402f9bcd2e
Parent:        b83a20b80a1f2f239e5c8496e819edd039965a6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:48:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

lvconvert: add extra check for existance of pointer

Coverity here is not fully-in-picture - but please it
with validation of pointer which currently cannot be null,
since we always return at least empty string.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a7df26d..c6cea0d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2340,7 +2340,7 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 	struct pipe_data pdata;
 	FILE *f;
 
-	if (!thin_repair[0]) {
+	if (!thin_repair || !thin_repair[0]) {
 		log_error("Thin repair commnand is not configured. Repair is disabled.");
 		return 0; /* Checking disabled */
 	}


