From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 23 Oct 2015 14:40:06 +0000 (UTC)
Subject: master - thin: Fix typo in policy threshold message.
Message-ID: <20151023144006.DB72E60E8F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51735f09f79794d6609913b4c117f1a4a0e491fe
Commit:        51735f09f79794d6609913b4c117f1a4a0e491fe
Parent:        3a42c13ccf151c3afdeab362c8541b5d249fb01e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 23 15:38:31 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 23 15:38:31 2015 +0100

thin: Fix typo in policy threshold message.

---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 738343f..19032e9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4438,8 +4438,8 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
 					     lv_config_profile(lv));
 		if (policy_threshold < 50) {
-			log_warn("WARNING: Thin pool autoextend threshold %d%% is set bellow "
-				 "minimal supported value 50%%.", policy_threshold);
+			log_warn("WARNING: Thin pool autoextend threshold %d%% is set below "
+				 "minimum supported 50%%.", policy_threshold);
 			policy_threshold = 50;
 		}
 	} else {


