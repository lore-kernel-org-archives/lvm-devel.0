From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 17 Mar 2017 11:03:55 -0400
Subject: master - raid: conditionally reject convert to striped/raid; fix
Message-ID: <201703171503.v2HF3tHp026053@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17a8f3d6f0fa26ab01d974af409d1d075d5815a0
Commit:        17a8f3d6f0fa26ab01d974af409d1d075d5815a0
Parent:        6ebf39da91678238ebea4f13cb1252bbc70238c5
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 17 16:03:35 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 17 16:03:35 2017 +0100

raid: conditionally reject convert to striped/raid; fix

Fix a logic flaw introduced in commit 17bee733d16e
preventing e.g. striped -> raid5 conversions.

Related: rhbz1191935
Related: rhbz1366296
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 7521e80..018e36d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6017,7 +6017,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	}
 
 	/* Prohibit any takeover in case sub LVs to be removed still exist after a previous reshape */
-	if (_get_available_removed_sublvs(lv, &available_slvs, &removed_slvs))
+	if (!_get_available_removed_sublvs(lv, &available_slvs, &removed_slvs))
 		return 0;
 	if (removed_slvs) {
 		log_error("Can't convert %s LV %s to %s containing sub LVs to remove after a reshape.",


