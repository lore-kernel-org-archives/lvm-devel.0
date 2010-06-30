From: Milan Broz <mbroz@redhat.com>
Date: Wed, 30 Jun 2010 13:31:18 +0200
Subject: [PATCH] Fix vgremove to allow removal of VG with missing PVs.
Message-ID: <1277897478-15448-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Inroduced by vgremove check function split...
---
 WHATS_NEW                  |    1 +
 test/t-activate-partial.sh |    3 +++
 tools/vgremove.c           |    2 +-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c415a3..b485a59 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Fix vgremove to allow removal of VG with missing PVs. (2.02.52)
   Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
   Add vg_mda_copies which displays the value of --vgmetadatacopies.
   Describe --vgmetadatacopies in lvm.conf and other man pages.
diff --git a/test/t-activate-partial.sh b/test/t-activate-partial.sh
index f0a95c5..15f5965 100644
--- a/test/t-activate-partial.sh
+++ b/test/t-activate-partial.sh
@@ -15,3 +15,6 @@ lvchange -v --refresh --partial $vg/mirror
 # also check that vgchange works
 vgchange -a n --partial $vg
 vgchange -a y --partial $vg
+
+# check vgremove
+vgremove -f $vg
\ No newline at end of file
diff --git a/tools/vgremove.c b/tools/vgremove.c
index b719ca2..56e18ef 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -49,7 +49,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	if (!vg_remove_check(vg)) {
+	if (!force && !vg_remove_check(vg)) {
 		stack;
 		return ECMD_FAILED;
 	}
-- 
1.7.1


