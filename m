From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 28 Oct 2016 19:54:20 +0000 (UTC)
Subject: master - lvconvert: fix raid repair regression
Message-ID: <20161028195420.4291E610D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e611f82a11fb9c489e73de8c05447ebe2cc26d9a
Commit:        e611f82a11fb9c489e73de8c05447ebe2cc26d9a
Parent:        8270ff5702e0fa846714ac7366aade84b3e85209
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Oct 28 21:45:00 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Oct 28 21:45:00 2016 +0200

lvconvert: fix raid repair regression

Limit prevention to raid1 as intended with commit 8270ff5702e0.

Related to rhbz1311765
---
 lib/metadata/raid_manip.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d15baf6..4d3d63f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -306,6 +306,9 @@ static int _raid_devs_sync_healthy(struct logical_volume *lv)
 	if (!_raid_in_sync(lv))
 		return 0;
 
+	if (!seg_is_raid1(first_seg(lv)))
+		return 1;
+
 	if (!lv_raid_dev_health(lv, &raid_health))
 		return_0;
 


