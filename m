From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Nov 2012 11:17:21 +0000 (UTC)
Subject: master - thin: add more unsupporte options for merge
Message-ID: <20121126111721.7A0D1A0DA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=953080e4fc271ad200736f3584f41e24dfe063ca
Commit:        953080e4fc271ad200736f3584f41e24dfe063ca
Parent:        683b1f0625a39084ed32ebce06a62d5a1fb4bf23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 26 11:14:36 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 26 12:15:32 2012 +0100

thin: add more unsupporte options for merge

Hmm, we need some smarter way to detect unsupported command
line options for various commands.
---
 tools/lvconvert.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7a01cce..fc58add 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -270,6 +270,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (lp->merge) {	/* Snapshot merge */
 		if (arg_count(cmd, regionsize_ARG) || arg_count(cmd, chunksize_ARG) ||
 		    arg_count(cmd, zero_ARG) || arg_count(cmd, regionsize_ARG) ||
+		    arg_count(cmd, poolmetadata_ARG) || arg_count(cmd, poolmetadatasize_ARG) ||
+		    arg_count(cmd, readahead_ARG) ||
 		    arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) {
 			log_error("Only --background and --interval are valid "
 				  "arguments for snapshot merge");


