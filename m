From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:08 +0000 (UTC)
Subject: master - cleanup: initilize percent to INVALID
Message-ID: <20120823124308.494D5A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb08f8652125513761e83c324a2c7e706ccda791
Commit:        eb08f8652125513761e83c324a2c7e706ccda791
Parent:        c6f680ee4945f22670d133ba341bb670c1d0a474
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 20 12:05:00 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

cleanup: initilize percent to INVALID

Always initialize percent to INVALID value, in case target
would have forget to setup this value somehow.
---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 43bcd49..c8a1e35 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -514,11 +514,11 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
 	int first_time = 1;
-	percent_t percent;
+	percent_t percent = PERCENT_INVALID;
 
 	uint64_t total_numerator = 0, total_denominator = 0;
 
-	*overall_percent = PERCENT_INVALID;
+	*overall_percent = percent;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
 				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))


