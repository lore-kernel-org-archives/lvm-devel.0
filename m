From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:12 +0000 (UTC)
Subject: master - thin: enable resize for thin pool metadata LV
Message-ID: <20130611120912.9CC5860DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c888c925b8d561158c3cea6d4f5ea4e173848c00
Commit:        c888c925b8d561158c3cea6d4f5ea4e173848c00
Parent:        87aca628d6b477ec4f0b6dac7d4895b31253a6e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:11:54 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:07:51 2013 +0200

thin: enable resize for thin pool metadata LV

Support 'clasic' way of resizing of metadata LV.
Normally we disallow to work with internal 'invisible' devices.
But in this case we can make an exception and if user has some
special needs how to extend thin pool metadata LV - support it.

After resize of metadata LV, the pool will be suspended and resumed,
to be notified of this change.
---
 tools/lvresize.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 6de3b3b..bb9a535 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -530,7 +530,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return ECMD_FAILED;
 	}
 
-	if (!lv_is_visible(lv)) {
+	if (!lv_is_visible(lv) &&
+	    !lv_is_thin_pool_metadata(lv)) {
 		log_error("Can't resize internal logical volume %s", lv->name);
 		return ECMD_FAILED;
 	}


