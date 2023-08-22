From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Tue, 22 Aug 2023 14:39:41 +0000
Subject: [Git][lvmteam/lvm2][main] CI: Add timeout
Message-ID: <64e4c8ad269b9_28a7a582335@gitlab-sidekiq-low-urgency-cpu-bound-v2-788b666f85-jm7t2.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at LVM team / lvm2


Commits:
73abdedb by Marian Csontos at 2023-08-22T16:39:32+02:00
CI: Add timeout

Increase timeout from default 1h to 2h.

- - - - -


1 changed file:

- .gitlab-ci.yml


Changes:

=====================================
.gitlab-ci.yml
=====================================
@@ -42,6 +42,7 @@ test-job:
     expire_in: 1 week
   tags:
       - ${TAG}
+  timeout: 2h
   script:
     # Common options go here, diffs to the above matrix
     - >



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/73abdedbc9bd200847b2030b8573546f6f0a44ee

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/73abdedbc9bd200847b2030b8573546f6f0a44ee
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230822/b337d220/attachment.htm>
