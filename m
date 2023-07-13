From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 13 Jul 2023 19:53:22 +0000
Subject: [Git][lvmteam/lvm2][main] debug: missed properly modify pointer type
Message-ID: <64b056326b5e8_282d2622862915@gitlab-sidekiq-low-urgency-cpu-bound-v2-db56db498-cz9p7.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
97fc0ca4 by Zdenek Kabelac at 2023-07-13T21:52:20+02:00
debug: missed properly modify pointer type

- - - - -


1 changed file:

- lib/log/log.c


Changes:

=====================================
lib/log/log.c
=====================================
@@ -248,7 +248,7 @@ static int _get_pid_starttime(int *pid, unsigned long long *starttime)
 		    "%*d %*u %*u %*u %*u " /* mjflt */
 		    "%*u %*u %*u %*d %*d " /* cstim */
 		    "%*d %*d %*d %*d " /* itrealvalue */
-		    "%llu", &starttime) == 1))
+		    "%llu", starttime) == 1))
 		return 1;
 
 	log_debug("Cannot parse content of %s.", statfile);



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/97fc0ca49bdb37ae0a094c45ab6a1bc9f31a38a2

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/97fc0ca49bdb37ae0a094c45ab6a1bc9f31a38a2
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230713/692db9ed/attachment-0001.htm>
