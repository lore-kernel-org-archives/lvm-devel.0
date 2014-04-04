From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:19:45 +0000 (UTC)
Subject: master - vgsplit: Mark cache moving code NOTREACHED.
Message-ID: <20140404001945.8964A60D76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7b8e0a10c500f94f8d7815d83d88f0a45f2c570
Commit:        e7b8e0a10c500f94f8d7815d83d88f0a45f2c570
Parent:        6d2a26f6b6031f275b89a0210a9c5436e006a544
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:19:04 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:19:04 2014 +0100

vgsplit: Mark cache moving code NOTREACHED.

---
 tools/vgsplit.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 150be1d..9d26079 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -299,6 +299,8 @@ static int _move_cache(struct volume_group *vg_from,
 		log_error("Unable to split VG while it contains cache LVs");
 		return 0;
 
+		/* NOTREACHED */
+
 		if (lv_is_cache(lv)) {
 			orig = seg_lv(seg, 0);
 			data = seg_lv(first_seg(seg->pool_lv), 0);


