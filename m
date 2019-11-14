From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:23 -0500
Subject: master - cov: check for retvalue
Message-ID: <39220.119111412072100169@us-mta-93.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=153e55c20e9a3810a1862314a6465179e1b53931
Commit:        153e55c20e9a3810a1862314a6465179e1b53931
Parent:        44bf9c9a6af2d76d4de04b456362abd4ed454ff9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:12:44 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: check for retvalue

---
 tools/pvck.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 231faf9..79fb8fb 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -359,7 +359,10 @@ static int _dump_all_text(struct cmd_context *cmd, const char *tofile, struct de
 			continue;
 		}
 
-		sscanf(line, "seqno = %u", &seqno);
+		if (sscanf(line, "seqno = %u", &seqno) != 1) {
+			log_warn("WARNING: Failed to parse seqno.");
+			seqno = 0; /* Skip? */
+		}
 
 		/*
 		 * The first three lines look like metadata with



