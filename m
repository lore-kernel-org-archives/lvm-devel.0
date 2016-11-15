From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Nov 2016 20:46:02 +0000 (UTC)
Subject: master - raid: Remove fixed FIXME
Message-ID: <20161115204602.F0E7A6036B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6de05cf5f5aa7c4125b20c11a13356b58ea2ff14
Commit:        6de05cf5f5aa7c4125b20c11a13356b58ea2ff14
Parent:        cd0736a94554750e0077f390770212c68da8fa4e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 15 20:45:55 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 15 20:45:55 2016 +0000

raid: Remove fixed FIXME

---
 lib/metadata/raid_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b88ddcc..cf4cce1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1055,7 +1055,6 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	seg_type(seg, idx) = AREA_UNASSIGNED;
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
 
-	/* FIXME Remove duplicated prefix? */
 	if (!(data_lv->name = _generate_raid_name(data_lv, "extracted", -1)))
 		return_0;
 


