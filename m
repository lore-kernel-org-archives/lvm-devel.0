From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 27 Feb 2015 13:37:23 +0000 (UTC)
Subject: master - lvchange: Allow -pr to change kernel only.
Message-ID: <20150227133723.AA15360614@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee4cd2c73774feeef3794c24865add1c28adb946
Commit:        ee4cd2c73774feeef3794c24865add1c28adb946
Parent:        5b154ae4a3d875009aa7a7d081c8e76cdb6dd50f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 27 13:38:26 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 27 13:38:26 2015 +0000

lvchange: Allow -pr to change kernel only.

---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cc974a6..bc2630c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Allow lvchange -p to change kernel state only if metadata state differs.
   Fix incorrect persistent .cache after report with label fields only (2.02.106).
   Reinstate PV tag recognition for pvs if reporting label fields only (2.02.105).
   Rescan devices before vgimport with lvmetad so exported VG is seen.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6ed953f..bf7e356 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -32,6 +32,13 @@ static int _lvchange_permission(struct cmd_context *cmd,
 	}
 
 	if (!(lv_access & LVM_WRITE) && !(lv->status & LVM_WRITE)) {
+		/* Refresh if it's read-only in metadata but read-write in kernel */
+		if (lv_info(cmd, lv, 0, &info, 0, 0) &&
+		    (info_obtained = 1, info.exists) && !info.read_only) {
+			log_print_unless_silent("Logical volume \"%s\" is already read-only.  Refreshing kernel state.",
+						lv->name);
+			return lv_refresh(cmd, lv);
+		}
 		log_error("Logical volume \"%s\" is already read only",
 			  lv->name);
 		return 0;


