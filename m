From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Wed, 30 Aug 2023 20:49:53 +0000
Subject: [Git][lvmteam/lvm2][main] vgchange: acquire an exclusive VG lock for refresh
Message-ID: <64efab71741d2_28a85205419d@gitlab-sidekiq-low-urgency-cpu-bound-v2-7f44b8899-94fnr.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
65d23a1d by wangzhiqiang at 2023-08-30T15:47:42-05:00
vgchange: acquire an exclusive VG lock for refresh

Concurrent vgchange --refresh commands can lead to hung
tasks in dm code.

Signed-off-by: wangzhiqiang &lt;wangzhiqiang95 at huawei.com&gt;

- - - - -


1 changed file:

- tools/vgchange.c


Changes:

=====================================
tools/vgchange.c
=====================================
@@ -1008,7 +1008,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (update)
 		flags |= READ_FOR_UPDATE;
-	else if (arg_is_set(cmd, activate_ARG))
+	else if (arg_is_set(cmd, activate_ARG) ||
+		 arg_is_set(cmd, refresh_ARG))
 		flags |= READ_FOR_ACTIVATE;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/65d23a1d75013f328e9a3a1914484514621822ef

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/65d23a1d75013f328e9a3a1914484514621822ef
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230830/35ee4dc7/attachment-0001.htm>
