From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  7 Oct 2013 22:53:49 +0000 (UTC)
Subject: master - lvchange: improve discards when pool active error
Message-ID: <20131007225349.43847612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4806f38d703c2d7cd01e0adc49505ccb7d010a17
Commit:        4806f38d703c2d7cd01e0adc49505ccb7d010a17
Parent:        761b5245193be548698495f2b2d2c089a5a72975
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 7 23:50:09 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 7 23:50:09 2013 +0100

lvchange: improve discards when pool active error

Existing message deemed misleading:
  Cannot change discards state for active pool volume

https://bugzilla.redhat.com/show_bug.cgi?id=994315
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ef2181d..5b35890 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Improve message when unable to change discards setting on active thin pool.
 
 Version 2.02.103 - 4th October 2013
 ===================================
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1d4f0a5..6ae9720 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -120,8 +120,7 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
 			    pool_is_active(lv))
-				log_error("Cannot change discards state for active "
-					  "pool volume \"%s\".", lv->name);
+				log_error("Cannot change support for discards while pool volume \"%s\" is active.", lv->name);
 			else {
 				first_seg(lv)->discards = discards;
 				update++;


