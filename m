From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 20 Sep 2013 03:34:32 +0000 (UTC)
Subject: master - RAID: Don't allow syncaction changes on non-RAID LVs
Message-ID: <20130920033432.D21F56036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c41c8b88610bff6a3352b93f6b5c70a3744c817
Commit:        2c41c8b88610bff6a3352b93f6b5c70a3744c817
Parent:        25bed9968155f43ef0b8832383ef711e7ae1685d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Sep 19 22:33:01 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Sep 19 22:33:01 2013 -0500

RAID: Don't allow syncaction changes on non-RAID LVs

Don't allow syncaction or other RAID-type messages on non-RAID
logical volumes.
---
 lib/activate/activate.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index e5033c6..7b535c6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -896,6 +896,12 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 	struct dev_manager *dm;
 	struct dm_status_raid *status;
 
+	if (!seg_is_raid(first_seg(lv))) {
+		log_error("%s/%s must be a RAID logical volume to"
+			  " perform this action.", lv->vg->name, lv->name);
+		return 0;
+	}
+
 	if (!lv_is_active_locally(lv)) {
 		log_error("Unable to send message to an inactive logical volume.");
 		return 0;


