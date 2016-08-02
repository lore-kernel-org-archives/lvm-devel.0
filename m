From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Aug 2016 14:59:51 +0000 (UTC)
Subject: master - lvconvert: Forbid stripe parameters with --repair.
Message-ID: <20160802145951.DFF7A60B3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=804a397643a38b9c82d22eacaca2138f2af57bec
Commit:        804a397643a38b9c82d22eacaca2138f2af57bec
Parent:        d0d03f315bd988bab50e45c4907ab626a780e600
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 2 15:57:45 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 2 15:59:12 2016 +0100

lvconvert: Forbid stripe parameters with --repair.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e81ab0..aa839bd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Forbid stripe parameters with lvconvert --repair.
   Unify stripe size validation into get_stripe_params to catch missing cases.
   Further lvconvert validation logic refactoring.
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index dd0102f..80760c6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -449,7 +449,6 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
 					    repair_ARG,
 					    alloc_ARG, usepolicies_ARG,
-					    stripes_long_ARG, stripesize_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;


