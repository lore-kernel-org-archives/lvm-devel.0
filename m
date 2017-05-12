From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 12 May 2017 08:19:03 -0400
Subject: master - lvcreate: Fix last commit for virtual sizes.
Message-ID: <201705121219.v4CCJ3AB004139@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2583732165b72d616dc1c08cb7e9bc74fb5a6e6d
Commit:        2583732165b72d616dc1c08cb7e9bc74fb5a6e6d
Parent:        cf73f6cf61793e9d71391bb7a8f35162509898a4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 12 13:16:10 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 12 13:16:10 2017 +0100

lvcreate: Fix last commit for virtual sizes.

Don't stop when extents is 0 if a virtual size parameter was supplied
instead.
---
 tools/lvcreate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index dddf8ad..e83c130 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -407,7 +407,7 @@ static int _update_extents_params(struct volume_group *vg,
 		}
 	}
 
-	if (!lp->extents) {
+	if ((lcp->percent != PERCENT_NONE) && !lp->extents) {
 		log_error("Adjusted size of logical volume is 0 extents. Needs to be larger.");
 		return 0;
 	}


