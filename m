From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:38 +0000 (UTC)
Subject: master - cleanup: drop unneeded int test
Message-ID: <20150508131638.6C63060759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c46428fcde05c3126ac2a505580cadb792f8997
Commit:        3c46428fcde05c3126ac2a505580cadb792f8997
Parent:        950a21d58adc581f921847f5c356a45f4f9cce94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 10:54:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

cleanup: drop unneeded int test

Testing int  region_size > INT32_MAX is always false
so drop the test (Coverity).
---
 lib/metadata/lv_manip.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 85f727f..1251a5d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -774,9 +774,6 @@ int get_default_region_size(struct cmd_context *cmd)
 {
 	int region_size = _get_default_region_size(cmd);
 
-	if (region_size > INT32_MAX)
-		region_size = INT32_MAX;
-
 	if (region_size & (region_size - 1)) {
 		region_size = _round_down_pow2(region_size);
 		log_verbose("Reducing mirror region size to %u kiB (power of 2).",


