From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 11:12:36 +0000 (UTC)
Subject: master - raid: reread status when 0 is reported
Message-ID: <20150504111236.AC339610E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88421c883ebe20730e31e601d209f48b64b14ad0
Commit:        88421c883ebe20730e31e601d209f48b64b14ad0
Parent:        2d10a6f6aef9eb013986c40a8bd83db6f571472f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 11:25:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 13:09:05 2015 +0200

raid: reread status when 0 is reported

When kernel target reports sync status as 0%  it might as well mean
it's 100% in sync, just the target is in some race inconsistent
state - so reread once again and take a more optimistic value ;)

Patch tries to work around:
https://bugzilla.redhat.com/show_bug.cgi?id=1210637
---
 lib/metadata/raid_manip.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c786e89..0428eb0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -93,6 +93,20 @@ static int _raid_in_sync(struct logical_volume *lv)
 			  lv->vg->name, lv->name);
 		return 0;
 	}
+	if (sync_percent == DM_PERCENT_0) {
+		/*
+		 * Repeat read of status once more - since buggy kernel target
+		 * sometimes reports 0 even though the array is in 100% sync
+		 */
+		if (!lv_raid_percent(lv, &sync_percent)) {
+			log_error("Unable to determine sync status of %s/%s.",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+		if (sync_percent == DM_PERCENT_100)
+			log_warn("WARNING: Sync status for %s is inconsistent.",
+				 display_lvname(lv));
+	}
 
 	return (sync_percent == DM_PERCENT_100) ? 1 : 0;
 }


