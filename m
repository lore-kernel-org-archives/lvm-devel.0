From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Feb 2017 16:48:44 +0000 (UTC)
Subject: master - lvconvert: avoid setting segment flag
Message-ID: <20170207164844.1C5A960F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69fe8729f3d60b0c9b9a0b2db6b36e38c00b9127
Commit:        69fe8729f3d60b0c9b9a0b2db6b36e38c00b9127
Parent:        46a772fbc4e121f8e9e65d3be022bbace79be1f2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 7 17:48:17 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 7 17:48:17 2017 +0100

lvconvert: avoid setting segment flag

Fix:
- don't set SEG_RAID in _convert_mirror_to_raid1() errounously

Related: rhbz1366296
---
 lib/metadata/raid_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6efbc5c..f55d3d8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2196,7 +2196,6 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 	lv->status &= ~MIRROR;
 	lv->status &= ~MIRRORED;
 	lv->status |= RAID;
-	seg->status |= SEG_RAID;
 
 	if (!lv_update_and_reload(lv))
 		return_0;


