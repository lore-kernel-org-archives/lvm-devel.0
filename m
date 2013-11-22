From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Nov 2013 18:18:20 +0000 (UTC)
Subject: master - toollib: Avoid undefined ignore_vg parameter.
Message-ID: <20131122181820.A749B60C46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c1f281b43175e69a73fcc59a9142fd374e8b70c
Commit:        4c1f281b43175e69a73fcc59a9142fd374e8b70c
Parent:        7c8abb29df2e8cc22c43f67117486e4e717110dd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 22 18:11:04 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 22 18:11:04 2013 +0000

toollib: Avoid undefined ignore_vg parameter.

Fix process_each_segment_in_pv to always set ret before calling ignore_vg().
---
 WHATS_NEW       |    1 +
 tools/toollib.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e47f0e5..647c810 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Fix undef value if skipped clustered VG ignored for toollib PV seg. (2.02.103)
   liblvm/python API Add ability to validate VG/LV names.
   liblvm/python API Add ability to create PV with arguments.
   liblvm/python API Fail VG reduce when insufficient metadata copies
diff --git a/tools/toollib.c b/tools/toollib.c
index b3bfd1d..90a7cb8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -510,10 +510,10 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		vg_name = pv_vg_name(pv);
 
 		vg = vg_read(cmd, vg_name, NULL, 0);
-		if (ignore_vg(vg, vg_name, 0, &ret)) {
+		if (ignore_vg(vg, vg_name, 0, &ret_max)) {
 			release_vg(vg);
 			stack;
-			return ret;
+			return ret_max;
 		}
 
 		/*


