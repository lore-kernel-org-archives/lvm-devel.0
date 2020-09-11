From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:42 +0000 (GMT)
Subject: master - lv_manip: even better rounding
Message-ID: <20200911195342.BD06B386F024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b798554a20147535566576fce8d2c839a090cf84
Commit:        b798554a20147535566576fce8d2c839a090cf84
Parent:        3f2e9e35467a2a92837a9859b150cf091411583b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 13:31:29 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 13:37:04 2020 +0200

lv_manip: even better rounding

---
 lib/metadata/lv_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e2c0f957b..3c781dcf9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4940,7 +4940,8 @@ static uint32_t _adjust_amount(dm_percent_t percent, int policy_threshold, int p
 	 * Keep using DM_PERCENT_1 units for better precision.
 	 * Round-up to needed percentage value
 	 */
-	percent = ((percent + policy_threshold - 1) / policy_threshold) / (DM_PERCENT_1 / 100) - 100;
+	policy_threshold *= (DM_PERCENT_1 / 100);
+	percent = (percent + policy_threshold - 1) / policy_threshold - 100;
 
 	/* Use it if current policy amount is smaller */
 	return (policy_amount < percent) ? (uint32_t) percent : (uint32_t) policy_amount;


