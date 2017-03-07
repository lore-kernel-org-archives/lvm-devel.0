From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 17:28:42 -0500
Subject: master - raid: define seg->extents_copied
Message-ID: <201703072228.v27MSg3W030887@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a5561e5ab5c916df8f90cc880ce2acb04ee2ecb
Commit:        3a5561e5ab5c916df8f90cc880ce2acb04ee2ecb
Parent:        aedac100f9474bb9b5184f9c6efbc25d49eb742a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 23:28:09 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 23:28:09 2017 +0100

raid: define seg->extents_copied

seg->extents_copied has to be defined properly on reducing
the size of a raid LV or conversion from raid5 with 1 stripe
to raid1 will fail.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/lv_manip.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f0c3058..90c61aa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1393,6 +1393,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		lv->le_count -= extents;
 
 	lv->size = (uint64_t) lv->le_count * lv->vg->extent_size;
+	if (seg)
+		seg->extents_copied = seg->len;
 
 	if (!delete)
 		return 1;


