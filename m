From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 4 Oct 2017 11:06:31 -0400
Subject: master - raid: enhance conversion rejection message
Message-ID: <201710041506.v94F6VsX008001@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a95f656d0df0fb81d68fa27bfee2350953677174
Commit:        a95f656d0df0fb81d68fa27bfee2350953677174
Parent:        32c87d56b12e9b6b8e6e1e7e85178abacf19811a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 4 17:05:59 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 4 17:05:59 2017 +0200

raid: enhance conversion rejection message

Related: rhbz1439399
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 72223ca..885a1ca 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6423,7 +6423,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* https://bugzilla.redhat.com/1439399 */
 	if (lv_is_origin(lv)) {
-		log_error("Can't convert snapshot origin %s.", display_lvname(lv));
+		log_error("Can't convert RAID LV %s while under snapshot.", display_lvname(lv));
 		return 0;
 	}
 


