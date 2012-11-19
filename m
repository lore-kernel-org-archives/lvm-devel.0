From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 15:28:30 +0000 (UTC)
Subject: master - thin: update recent patchset
Message-ID: <20121119152830.E1B9924AA@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=999952c5b9a21451d1b76c53a7dca615cd815113
Commit:        999952c5b9a21451d1b76c53a7dca615cd815113
Parent:        c907ee0351b226eb9e89929afcfc008985f32f97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 16:23:18 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 16:28:00 2012 +0100

thin: update recent patchset

Parse pool params only for creation of thin pools.
---
 tools/lvcreate.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 470084c..801ff64 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -785,8 +785,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
-	    !get_pool_params(cmd, &lp->chunk_size, &lp->discards,
-			     &lp->poolmetadatasize, &lp->zero) ||
+	    (lp->create_thin_pool &&
+	     !get_pool_params(cmd, &lp->chunk_size, &lp->discards,
+			      &lp->poolmetadatasize, &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd))
 		return_0;


