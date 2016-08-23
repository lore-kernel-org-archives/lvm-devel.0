From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 23 Aug 2016 15:10:17 +0000 (UTC)
Subject: master - dmeventd: Add fixed timeout when unmonitoring.
Message-ID: <20160823151017.7EF2C60EC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d65ce9711dace22cebb370b0d93fd7a98213bd8
Commit:        2d65ce9711dace22cebb370b0d93fd7a98213bd8
Parent:        db0e34535c82cfb73af19a7673de82881ad2468c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 23 16:09:18 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 23 16:09:18 2016 +0100

dmeventd: Add fixed timeout when unmonitoring.

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 22e3afa..f4d3a17 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1853,7 +1853,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 			continue;
 
 		if (new_unmonitor) {
-			if (!target_register_events(cmd, dso, lv, 0, 0, 0)) {
+			if (!target_register_events(cmd, dso, lv, 0, 0, 10)) {
 				log_error("%s: segment unmonitoring failed.",
 					  display_lvname(lv));
  


