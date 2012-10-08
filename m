From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Oct 2012 10:17:06 +0000 (UTC)
Subject: master - lvconvert: disable convertion of thin to mirrors
Message-ID: <20121008101706.CCD1D337A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b07bd3f9116ade9bb5931485eaa260f5141db6b
Commit:        5b07bd3f9116ade9bb5931485eaa260f5141db6b
Parent:        6e312c56adb04e709819868c6fa89f5984013a65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 5 11:06:08 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 8 12:16:53 2012 +0200

lvconvert: disable convertion of thin to mirrors

For now this convertions is not supported, thus disabled.
The only supported conversion for now is to create mirrored thin pools
from mirrored devices.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44682a6..e39a36e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Disallow convertion of thins to mirrors.
   Fix lvm2api data_percent reporting for thin volumes.
   Do not allow RAID LVs in a clustered volume group.
   Update lvconvert to support stacking of devs for thin meta/data devs.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 41bc585..132a69d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1494,6 +1494,13 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 		return 0;
 	}
 
+	/* TODO: decide what should be done here */
+	if (lv_is_thin_type(lv)) {
+		log_error("Converting segment type for %s/%s to mirror is not yet supported.",
+			 lv->vg->name, lv->name);
+		return 0;
+	}
+
 	/* Adjust mimage and/or log count */
 	if (!_lvconvert_mirrors_parse_params(cmd, lv, lp,
 					     &old_mimage_count, &old_log_count,


