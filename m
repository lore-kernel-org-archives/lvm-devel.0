From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 24 Jun 2013 11:17:44 +0000 (UTC)
Subject: master - cleanup: Remove message used for development
Message-ID: <20130624111744.815D860CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88288ab43322c94750c25db249451be769931984
Commit:        88288ab43322c94750c25db249451be769931984
Parent:        c9e8e7c235a14d8ada78b88d467f659b8e72554b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 24 06:16:39 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 24 06:16:39 2013 -0500

cleanup:  Remove message used for development

Failed to clean out all messages used during development.
---
 tools/lvcreate.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 05f3b13..972b36a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -591,9 +591,6 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
 	lp->min_recovery_rate /= 2;
 	lp->max_recovery_rate /= 2;
-	log_error("min = %u, max = %u",
-		  lp->min_recovery_rate,
-		  lp->max_recovery_rate);
 
 	if (lp->max_recovery_rate &&
 	    (lp->max_recovery_rate < lp->min_recovery_rate)) {


