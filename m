From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Jun 2018 11:59:53 -0400
Subject: master - Print advice about changing clustered VGs to shared
Message-ID: <201806181559.w5IFxrA7013660@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=565df4e7321243614fd18c6a45d1f890ab92956b
Commit:        565df4e7321243614fd18c6a45d1f890ab92956b
Parent:        428514a07f4bd270f6a137f08be1b2818312bdbd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 18 10:59:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 18 10:59:11 2018 -0500

Print advice about changing clustered VGs to shared

---
 tools/toollib.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ebf2509..f0cf78e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -173,6 +173,8 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 	return vg_name;
 }
 
+static int _printed_clustered_vg_advice = 0;
+
 /*
  * Three possible results:
  * a) return 0, skip 0: take the VG, and cmd will end in success
@@ -206,10 +208,18 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 
 	if (read_error & FAILED_CLUSTERED) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Cannot access clustered VG %s, see lvmlockd(8).", vg->name);
+			log_error("Cannot access clustered VG %s.", vg->name);
+			if (!_printed_clustered_vg_advice) {
+				_printed_clustered_vg_advice = 1;
+				log_error("See lvmlockd(8) for changing a clvm/clustered VG to a shared VG.");
+			}
 			return 1;
 		} else {
 			log_warn("Skipping clustered VG %s.", vg_name);
+			if (!_printed_clustered_vg_advice) {
+				_printed_clustered_vg_advice = 1;
+				log_error("See lvmlockd(8) for changing a clvm/clustered VG to a shared VG.");
+			}
 			*skip = 1;
 			return 0;
 		}


