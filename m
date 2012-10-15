From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 12:10:09 +0000 (UTC)
Subject: master - thin: disable conversion of thin-pool to read-only
Message-ID: <20121015121009.C3788A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3899056d94d14eaa80c49e4a5a52c8e7865f08a
Commit:        b3899056d94d14eaa80c49e4a5a52c8e7865f08a
Parent:        faa9a520857ecae31ab6e8f880a040e1e1b5363a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 13:41:38 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:09:11 2012 +0200

thin: disable conversion of thin-pool to read-only

This change is not yet supported.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 53f3fe9..b2b7c35 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Prohibit not yet supported change of thin-pool to read-only.
   Support creation of read-only thin volumes (lvcreate -p r).
   Using autoextend percent 0 for thin pool fails 'lvextend --use-policies'.
   Introduce blkdeactivate script.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index b787672..85253ef 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -51,6 +51,12 @@ static int lvchange_permission(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!(lv_access & LVM_WRITE) && lv_is_thin_pool(lv)) {
+		log_error("Change permissions of thin pool \"%s\" not "
+			  "yes supported.", lv->name);
+		return 0;
+	}
+
 	if (lv_access & LVM_WRITE) {
 		lv->status |= LVM_WRITE;
 		log_verbose("Setting logical volume \"%s\" read/write",


