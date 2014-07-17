From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:04 +0000 (UTC)
Subject: master - lvconvert: add missing option for repair
Message-ID: <20140717142904.B7BB16100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04acf7a8d0713c858df893584401e96100f9d9d5
Commit:        04acf7a8d0713c858df893584401e96100f9d9d5
Parent:        3e4f24115a9b5dc8f60436195bffc60100d02620
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 17 11:28:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:14:18 2014 +0200

lvconvert: add missing option for repair

Few more option needs to be allowed with --repair.
(in-release fix).
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2ad1603..8370b49 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -392,8 +392,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	if (arg_count(cmd, repair_ARG) &&
 	    !arg_is_only_set(cmd, "cannot be used with --repair",
 			     repair_ARG,
-			     use_policies_ARG,
+			     alloc_ARG, use_policies_ARG,
 			     stripes_long_ARG, stripesize_ARG,
+			     force_ARG, noudevsync_ARG, test_ARG,
 			     -1))
 		return_0;
 


