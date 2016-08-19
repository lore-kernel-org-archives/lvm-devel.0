From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Aug 2016 22:47:07 +0000 (UTC)
Subject: master - lvconvert: Don't allow --repair on raid0 LVs.
Message-ID: <20160819224707.8B00F601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88e6abc5a091bbe8d826968eafe27936df0e260c
Commit:        88e6abc5a091bbe8d826968eafe27936df0e260c
Parent:        bf0eaafa6b81a271d40031b337c614bb9b56159a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 19 23:42:01 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 19 23:42:01 2016 +0100

lvconvert: Don't allow --repair on raid0 LVs.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    8 +++++++-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 764cc73..5a258c1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.165 - 
 ===================================
+  Don't allow lvconvert --repair on raid0 devices.
   No longer adjust incorrect number of raid stripes supplied to lvcreate.
   Move lcm and gcd to lib/misc.
   Suppress some unnecessary --stripesize parameter warnings.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ac019ec..fefec7c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1963,7 +1963,13 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			return 0;
 		}
 
-		if (!seg_is_striped(seg) && !lv_raid_percent(lv, &sync_percent)) {
+		if (seg_is_striped(seg)) {
+			log_error("Cannot repair LV %s of type raid0.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		if (!lv_raid_percent(lv, &sync_percent)) {
 			log_error("Unable to determine sync status of %s.",
 				  display_lvname(lv));
 			return 0;


