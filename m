From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Mon, 24 Jul 2023 17:04:58 +0000
Subject: [Git][lvmteam/lvm2][main] vgmknodes: skipping thin pool is not an error
Message-ID: <64beaf3a40441_29bb86406026c@gitlab-sidekiq-low-urgency-cpu-bound-v2-85cdd7cd69-q2rzj.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
e3cc3e55 by Paul van Genderen-Tjie A Loi at 2023-07-24T12:03:06-05:00
vgmknodes: skipping thin pool is not an error

- - - - -


1 changed file:

- lib/activate/dev_manager.c


Changes:

=====================================
lib/activate/dev_manager.c
=====================================
@@ -2066,6 +2066,8 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 		/* read-only component LV is also made visible */
 		if (_lv_has_mknode(lv) || (dminfo.read_only && lv_is_component(lv)))
 			r = _dev_manager_lv_mknodes(lv);
+		else
+			r = 1;
 	} else
 		r = _dev_manager_lv_rmnodes(lv);
 



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e3cc3e55c8e75f20997f321bfac766859337bef6

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/e3cc3e55c8e75f20997f321bfac766859337bef6
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230724/9e1ea47a/attachment-0001.htm>
