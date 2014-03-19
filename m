From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:08 +0000 (UTC)
Subject: master - pvdisplay: use log_print_unless_silent for info messages
Message-ID: <20140319000208.66D1260FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52525bde04e72245224546caaacde2a3b15cad9d
Commit:        52525bde04e72245224546caaacde2a3b15cad9d
Parent:        013f5f4550816b0ac0d7f7a92ce763624b351319
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:35:27 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:48:39 2014 +0100

pvdisplay: use log_print_unless_silent for info messages

---
 tools/pvdisplay.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 35fb75b..198267c 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -63,12 +63,12 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 	}
 
 	if (pv_status(pv) & EXPORTED_VG)
-		log_print("Physical volume \"%s\" of volume group \"%s\" "
-			  "is exported", pv_name, pv_vg_name(pv));
+		log_print_unless_silent("Physical volume \"%s\" of volume group \"%s\" "
+					"is exported", pv_name, pv_vg_name(pv));
 
 	if (is_orphan(pv))
-		log_print("\"%s\" is a new physical volume of \"%s\"",
-			  pv_name, display_size(cmd, size));
+		log_print_unless_silent("\"%s\" is a new physical volume of \"%s\"",
+					pv_name, display_size(cmd, size));
 
 	if (arg_count(cmd, colon_ARG)) {
 		pvdisplay_colons(pv);


