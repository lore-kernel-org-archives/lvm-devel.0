From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 28 Sep 2015 19:47:06 +0000 (UTC)
Subject: master - raid: Fail if kernel status denominator is zero.
Message-ID: <20150928194706.650A06029C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d94ff2092709c600524f732b8bc98cd692562bcb
Commit:        d94ff2092709c600524f732b8bc98cd692562bcb
Parent:        0173c260d8270465f1895044b34609008962cc00
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 28 20:45:44 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 28 20:45:44 2015 +0100

raid: Fail if kernel status denominator is zero.

---
 lib/raid/raid.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index f75e1f7..0814cba 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -280,8 +280,8 @@ static int _raid_target_percent(void **target_state,
 		else
 			break;
 	}
-	if (!pos || (sscanf(pos, FMTu64 "/" FMTu64 "%n",
-			    &numerator, &denominator, &i) != 2)) {
+	if (!pos || (sscanf(pos, FMTu64 "/" FMTu64 "%n", &numerator, &denominator, &i) != 2) ||
+	    !denominator) {
 		log_error("Failed to parse %s status fraction: %s",
 			  (seg) ? seg->segtype->name : "segment", params);
 		return 0;


