From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 14:05:29 +0000 (GMT)
Subject: main - gcc: hide uninitialized warning with older gcc
Message-ID: <20210201140529.26E42386F448@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=026d94d882635f859814280573d1198203652d29
Commit:        026d94d882635f859814280573d1198203652d29
Parent:        48030389ceb43a6ae90568e5cf7475bc7715ca47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 14:54:49 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:54:49 2021 +0100

gcc: hide uninitialized warning with older gcc

---
 lib/raid/raid.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 126b22d43..6344200f5 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -472,7 +472,7 @@ static int _check_feature(const struct raid_feature *feature, uint32_t maj, uint
 /* Check availability of raid10 taking data copies into consideration. */
 static bool _raid10_is_available(const struct logical_volume *lv)
 {
-	uint32_t i, rebuilds_per_group, s;
+	uint32_t i, rebuilds_per_group = 0, s;
 	const uint32_t copies = 2; /* FIXME: we only support 2-way mirrors (i.e. 2 data copies) in RAID10 for now. */
 	struct lv_segment *seg = first_seg(lv); /* We only have one segment in RaidLVs for now. */
 


