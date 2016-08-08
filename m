From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  8 Aug 2016 22:14:08 +0000 (UTC)
Subject: master - lvconvert: Fix repair and replace routing.
Message-ID: <20160808221408.85B2A6104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5a5fd3669914337f85fc5c12e867680eb3f58a9
Commit:        e5a5fd3669914337f85fc5c12e867680eb3f58a9
Parent:        dad02900f18d3ef9b85d78f2e42434d92e6d84c9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 8 23:13:34 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 8 23:13:34 2016 +0100

lvconvert: Fix repair and replace routing.

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7c014e0..72b4931 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1919,7 +1919,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 1;
 		}
 		goto try_new_takeover_or_reshape;
-	} else if (!*lp->type_str || seg->segtype == lp->segtype) {
+	} else if (!lp->repair && !lp->replace && (!*lp->type_str || seg->segtype == lp->segtype)) {
 		log_error("Conversion operation not yet supported.");
 		return 0;
 	}


