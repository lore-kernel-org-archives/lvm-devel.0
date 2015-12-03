From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:43:03 +0000 (UTC)
Subject: master - lvconvert: Reinstate raid merge after splitmirror.
Message-ID: <20151203174303.987AD60AB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c24d913c47d9639df277b613cee9b5a57aca0762
Commit:        c24d913c47d9639df277b613cee9b5a57aca0762
Parent:        89418c1253db901eb6f22b342bc5d98d63aa32e5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Dec 3 17:40:10 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Dec 3 17:40:10 2015 +0000

lvconvert: Reinstate raid merge after splitmirror.

After commit 46c8d6bb8ae91ee67c8633496cc6c3d92bb4f3ce
(lvconvert: Improve message for raid without -m)
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 82b804f..d480f6a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1734,7 +1734,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return 0;
 	}
 
-	if (seg_is_linear(seg) && !arg_count(cmd, mirrors_ARG)) {
+	if (seg_is_linear(seg) && !lp->merge_mirror && !arg_count(cmd, mirrors_ARG)) {
 		log_error("Raid conversions require -m/--mirrors");
 		return 0;
 	}


