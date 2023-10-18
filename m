From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 18 Oct 2023 00:26:15 +0000
Subject: [Git][lvmteam/lvm2][main] filters: fix condition
Message-ID: <652f262772690_2c7a4287c3453c@gitlab-sidekiq-low-urgency-cpu-bound-v2-65f69dcbf-m4g7v.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
2b01af3d by Zdenek Kabelac at 2023-10-18T02:19:15+02:00
filters: fix condition

During revork in commit cf46f4baeeaba5f79982e651c1c36c15476f7329
condition was inverted, the check for non-null string is needed.

- - - - -


1 changed file:

- lib/filters/filter-sysfs.c


Changes:

=====================================
lib/filters/filter-sysfs.c
=====================================
@@ -75,7 +75,7 @@ struct dev_filter *sysfs_filter_create(const char *sysfs_dir)
 	struct dev_filter *f;
 	size_t len;
 
-	if (!sysfs_dir || *sysfs_dir) {
+	if (!sysfs_dir || !*sysfs_dir) {
 		log_verbose("No proc filesystem found: skipping sysfs filter");
 		return NULL;
 	}



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/2b01af3de97576dc2d6e5a4897f1fc0488e67879

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/2b01af3de97576dc2d6e5a4897f1fc0488e67879
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231018/fd916fa3/attachment-0001.htm>
