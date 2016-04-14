From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 14 Apr 2016 21:41:57 +0000 (UTC)
Subject: master - activation: Add LV name to a debug message.
Message-ID: <20160414214157.F2FB161030@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff09bda7d585bbf743048965142e5b0ec881b896
Commit:        ff09bda7d585bbf743048965142e5b0ec881b896
Parent:        f0179fac315b630aa4c475d2441dd3b5b12f0c6d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 14 22:41:25 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 14 22:41:25 2016 +0100

activation: Add LV name to a debug message.

---
 lib/activate/activate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ca82518..8e6ee33 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2309,7 +2309,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if (info.exists && !info.suspended && info.live_table &&
 	    (info.read_only == read_only_lv(lv, laopts))) {
 		r = 1;
-		log_debug_activation("Volume is already active.");
+		log_debug_activation("LV %s is already active.", display_lvname(lv));
 		goto out;
 	}
 


