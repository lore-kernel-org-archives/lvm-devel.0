From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Jul 2013 12:04:03 +0000 (UTC)
Subject: master - cleanup: remove tab
Message-ID: <20130708120403.5820F6034E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccf3dd60f2a486f8ac1b9788ca6378b1dc88827d
Commit:        ccf3dd60f2a486f8ac1b9788ca6378b1dc88827d
Parent:        c5d253f3150eb10f24accb8d750f1efbf9d0a904
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 16:18:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 8 14:01:41 2013 +0200

cleanup: remove tab

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a0e6af7..3ea1987 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2050,7 +2050,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			return_0;
 
 		if (!(metadata_lv = alloc_pool_metadata(pool_lv, metadata_name,
-							lp->read_ahead,	lp->stripes,
+							lp->read_ahead, lp->stripes,
 							lp->stripe_size,
 							lp->poolmetadata_size,
 							lp->alloc, lp->pvh)))


