From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:46 +0000 (GMT)
Subject: dev-next - raid: restore mirror handling in _raid_in_sync
Message-ID: <20210322153946.2BB96385480A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05920e3818b22c24dde59b3e562fe156466f83f2
Commit:        05920e3818b22c24dde59b3e562fe156466f83f2
Parent:        edcc410835641c9ea7bd15810657e0d16608c00f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 20 10:35:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 10:52:24 2021 +0100

raid: restore mirror handling in _raid_in_sync

Function is not having the best name since it does check
no just raid LVs to be in sync.

Restore the mirror percentage checking - although without retries,
since only raid target is currently known to need it - for other
types it would be ATM a bug to get inconsistent result.
---
 lib/metadata/raid_manip.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 33fd017cb..05b7caf9c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -398,7 +398,14 @@ static int _raid_in_sync(const struct logical_volume *lv)
 	if (seg_is_striped(first_seg(lv)))
 		return 1;
 
-	do {
+	if (!lv_is_raid(lv)) {
+		/* For non raid - fallback to mirror percentage */
+		if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &sync_percent, NULL)) {
+			log_error("Cannot determine sync percentage of %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+	} else do {
 		/*
 		 * FIXME We repeat the status read here to workaround an
 		 * unresolved kernel bug when we see 0 even though the


