From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 19 Jun 2017 15:41:17 -0400
Subject: master - lvconvert: enhance message
Message-ID: <201706191941.v5JJfH7x003804@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1a1c20e95974811ffa541f02723a9390132d10b
Commit:        e1a1c20e95974811ffa541f02723a9390132d10b
Parent:        f342e803ba3c32890a2b08736fa94bdd541d5e9c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jun 19 21:40:38 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jun 19 21:40:38 2017 +0200

lvconvert: enhance message

Enhance message introduced by last
commit f342e803ba3c32890a2b08736fa94bdd541d5e9c.

Related: rhbz1439399
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0a08ca9..95ce3b5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6314,7 +6314,7 @@ int lv_raid_convert(struct logical_volume *lv,
 
 	/* BZ1439399 */
 	if (lv_is_origin(lv)) {
-		log_error("Can't convert %s under snapshot.", display_lvname(lv));
+		log_error("Can't convert snapshot origin %s.", display_lvname(lv));
 		return 0;
 	}
 


