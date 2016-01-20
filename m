From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 20 Jan 2016 02:54:51 +0000 (UTC)
Subject: master - activation: remote node check doesn't work yet
Message-ID: <20160120025451.1B23A60EB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2da7525c8371a94ee8fe700ff021e3b14dd2fd34
Commit:        2da7525c8371a94ee8fe700ff021e3b14dd2fd34
Parent:        509410bbbcc6fb72e985029e98c19315da36318a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 20 02:54:11 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 20 02:54:11 2016 +0000

activation: remote node check doesn't work yet

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index aa24a5f..ac7dacb 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1381,7 +1381,7 @@ static int _lv_is_active(const struct logical_volume *lv,
 	if (skip_cluster_query)
 		goto out;
 
-	if ((r = cluster_lock_held(lv->lvid.s, NODE_REMOTE, &e)) >= 0)
+	if ((r = cluster_lock_held(lv->lvid.s, "", &e)) >= 0)
 		goto out;
 
 	/*


