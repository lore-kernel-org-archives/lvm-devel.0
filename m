From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:38 +0000 (UTC)
Subject: master - lvrename: fix name length validation
Message-ID: <20140331100638.7A0E260AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3e4934a153a3113038d8458fb62781b234287ea
Commit:        d3e4934a153a3113038d8458fb62781b234287ea
Parent:        caa429da2e58ad65ecfc8836f5f64c54395a8793
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:40:52 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:02:18 2014 +0200

lvrename: fix name length validation

This test for LV name restriction check name of device is below 128
chars (which is enforced by dm target).
Thus it should not count with device name.
(Though the test for PATH_MAX size should be probably also added,
but this is runtime test, since theoretically devpath might differ in cluster)
---
 WHATS_NEW        |    1 +
 tools/lvrename.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b5ee541..1760a6b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Validate length of new LV name in lvrename to not exceed 127 characters.
   Add explict error message when using lvdisplay -c -m.
   Update man pages for pv/vg/lvdisplay.
   Report error when running pvscan with free argument (i.e. PV name).
diff --git a/tools/lvrename.c b/tools/lvrename.c
index dd66ba4..0fea039 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -71,10 +71,10 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		lv_name_new = st + 1;
 
 	/* Check sanity of new name */
-	maxlen = NAME_LEN - strlen(vg_name) - strlen(cmd->dev_dir) - 3;
+	maxlen = NAME_LEN - strlen(vg_name) - 3;
 	if (strlen(lv_name_new) > maxlen) {
-		log_error("New logical volume path exceeds maximum length "
-			  "of %" PRIsize_t "!", maxlen);
+		log_error("New logical volume name \"%s\" may not exceed %"
+			  PRIsize_t " characters.", lv_name_new, maxlen);
 		return EINVALID_CMD_LINE;
 	}
 


