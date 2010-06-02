From: Milan Broz <mbroz@redhat.com>
Date: Wed,  2 Jun 2010 18:19:49 +0200
Subject: [PATCH] Require partial option in lvchange --refresh for partials LVs.
Message-ID: <1275495589-15705-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We must not refresh LV if some PVs are missing and partial activation
was not requested.

Fix https://bugzilla.redhat.com/show_bug.cgi?id=598886
---
 test/t-activate-partial.sh |    2 ++
 tools/toollib.c            |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/t-activate-partial.sh b/test/t-activate-partial.sh
index dd978f5..f0a95c5 100644
--- a/test/t-activate-partial.sh
+++ b/test/t-activate-partial.sh
@@ -9,6 +9,8 @@ disable_dev $dev1
 not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
 lvchange -v --partial -a y $vg/mirror
+not lvchange -v --refresh $vg/mirror
+lvchange -v --refresh --partial $vg/mirror
 
 # also check that vgchange works
 vgchange -a n --partial $vg
diff --git a/tools/toollib.c b/tools/toollib.c
index 4022a32..e6791e2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1248,6 +1248,12 @@ int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int r = 0;
 
+	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
+		log_error("Refusing refresh of partial LV %s. Use --partial to override.",
+			  lv->name);
+		goto out;
+	}
+
 	r = suspend_lv(cmd, lv);
 	if (!r)
 		goto_out;
-- 
1.7.1


