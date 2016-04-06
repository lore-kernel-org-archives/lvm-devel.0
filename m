From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:42 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20160406095542.9D43860FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9be7bca4be913f3edc4d4f838d72329475fa8655
Commit:        9be7bca4be913f3edc4d4f838d72329475fa8655
Parent:        0584e85736b164d07434619622d6d06ad15fe690
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 6 10:28:02 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

cleanup: indent

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7afb439..985d6b9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1827,7 +1827,7 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	const struct logical_volume *lv_pre_to_free = NULL;
 	struct logical_volume *lv_pre_tmp;
 	struct seg_list *sl;
-        struct lv_segment *snap_seg;
+	struct lv_segment *snap_seg;
 	struct lvinfo info;
 	int r = 0, lockfs = 0, flush_required = 0;
 	struct detached_lv_data detached;


