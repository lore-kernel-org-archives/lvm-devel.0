From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Mon, 11 Sep 2023 17:20:37 +0000
Subject: [Git][lvmteam/lvm2][main] lvresize: fix 32 bit overflow in size calculation
Message-ID: <64ff4c6556015_28846a84984fd@gitlab-sidekiq-low-urgency-cpu-bound-v2-5f6c477dc8-fhd6n.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
fa496513 by David Teigland at 2023-09-11T12:18:12-05:00
lvresize: fix 32 bit overflow in size calculation

- - - - -


1 changed file:

- lib/metadata/lv_manip.c


Changes:

=====================================
lib/metadata/lv_manip.c
=====================================
@@ -6445,7 +6445,7 @@ static int _fs_reduce(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* extent_size units is SECTOR_SIZE (512) */
-	newsize_bytes_lv = lp->extents * lv->vg->extent_size * SECTOR_SIZE;
+	newsize_bytes_lv = (uint64_t) lp->extents * lv->vg->extent_size * SECTOR_SIZE;
 	newsize_bytes_fs = newsize_bytes_lv;
 
 	/*
@@ -6591,7 +6591,7 @@ static int _fs_extend(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 
 	/* extent_size units is SECTOR_SIZE (512) */
-	newsize_bytes_lv = lp->extents * lv->vg->extent_size * SECTOR_SIZE;
+	newsize_bytes_lv = (uint64_t) lp->extents * lv->vg->extent_size * SECTOR_SIZE;
 	newsize_bytes_fs = newsize_bytes_lv;
 	if (fsinfo.needs_crypt) {
 		newsize_bytes_fs -= fsinfo.crypt_offset_bytes;



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/fa496513010976aac21584b5081529b76462f9a9

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/fa496513010976aac21584b5081529b76462f9a9
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230911/5026cffd/attachment.htm>
