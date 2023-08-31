From: David Teigland (@teigland) <gitlab@mg.gitlab.com>
Date: Thu, 31 Aug 2023 18:17:29 +0000
Subject: [Git][lvmteam/lvm2][main] lvmlockd: client mutex ordering
Message-ID: <64f0d939406c5_28a404c648@gitlab-sidekiq-low-urgency-cpu-bound-v2-54f99fbbc-nb4gf.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



David Teigland pushed to branch main at LVM team / lvm2


Commits:
c37416b6 by David Teigland at 2023-08-31T13:15:07-05:00
lvmlockd: client mutex ordering

Avoid deadlock between threads on mutexes (in theory.)

- - - - -


1 changed file:

- daemons/lvmlockd/lvmlockd-core.c


Changes:

=====================================
daemons/lvmlockd/lvmlockd-core.c
=====================================
@@ -4690,9 +4690,12 @@ static int dump_info(int *dump_len)
 
 	/*
 	 * clients
+	 * Proper lock order is client_mutex then cl->mutex,
+	 * but cl->mutex is already held so skip client info
+	 * if it would block.
 	 */
-
-	pthread_mutex_lock(&client_mutex);
+	if (pthread_mutex_trylock(&client_mutex))
+		goto print_ls;
 	list_for_each_entry(cl, &client_list, list) {
 		ret = print_client(cl, "client", pos, len);
 		if (ret >= len - pos) {
@@ -4706,6 +4709,7 @@ static int dump_info(int *dump_len)
 	if (rv < 0)
 		return rv;
 
+ print_ls:
 	/*
 	 * lockspaces with their action/resource/lock info
 	 */



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/c37416b6aac10521fe4fdc26618eb476bba0bd2f

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/c37416b6aac10521fe4fdc26618eb476bba0bd2f
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230831/67b7ba33/attachment.htm>
