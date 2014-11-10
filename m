From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:02 +0000 (UTC)
Subject: master - pools: after fail of vg_write no restore
Message-ID: <20141110210602.6FC5960AA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=138c2417c070eef5cdb9839a88efae5b601f4a49
Commit:        138c2417c070eef5cdb9839a88efae5b601f4a49
Parent:        94e4d5fcf51abdfd42df9299109fbc9d22f2f92b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 5 20:27:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 21:34:02 2014 +0100

pools: after fail of vg_write no restore

Revert part of commit 51a29e60564d537,
it's probably bad idea to continue with any recovery, when
vg_write() or vg_commit() fail - so it's better to leave it as it is.
---
 lib/metadata/lv_manip.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6292626..bedf4b6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6971,14 +6971,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->activate = CHANGE_AN;
 
 	/* store vg on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		if (seg_is_pool(lp)) {
-			/* Pool volumes have already created metadata LV */
-			stack;
-			goto revert_new_lv;
-		}
+	if (!vg_write(vg) || !vg_commit(vg))
+		/* Pool created metadata LV, but better avoid recover when vg_write/commit fails */
 		return_NULL;
-	}
 
 	backup(vg);
 


