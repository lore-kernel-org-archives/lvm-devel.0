From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 24 Jul 2016 00:41:34 +0000 (UTC)
Subject: master - raid_manip: Fix stripe_size type to uint32_t.
Message-ID: <20160724004134.D36306100B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea543b5c6f2f7fd9e7c54d8e33abc32049aafc6d
Commit:        ea543b5c6f2f7fd9e7c54d8e33abc32049aafc6d
Parent:        4a544ae272c172d0ba63096c488688a69f997e98
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Jul 24 01:35:04 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Jul 24 01:35:04 2016 +0100

raid_manip: Fix stripe_size type to uint32_t.

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2470532..ee05ae7 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2171,7 +2171,7 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	int force,				\
 	unsigned new_image_count,		\
 	const unsigned new_stripes,		\
-	unsigned new_stripe_size,		\
+	uint32_t new_stripe_size,		\
 	struct dm_list *allocate_pvs
 
 typedef int (*takeover_fn_t)(TAKEOVER_FN_ARGS);


