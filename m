From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Sat, 14 Oct 2023 21:38:55 +0000
Subject: [Git][lvmteam/lvm2][main] tests: old way to disable copy contructor
Message-ID: <652b0a6f462bb_2c1c974764814b4@gitlab-sidekiq-low-urgency-cpu-bound-v2-59d68cd46b-7gj6b.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
5cc54458 by Zdenek Kabelac at 2023-10-14T23:37:38+02:00
tests: old way to disable copy contructor

Mark them private.

- - - - -


1 changed file:

- test/lib/brick-shelltest.h


Changes:

=====================================
test/lib/brick-shelltest.h
=====================================
@@ -110,10 +110,13 @@ public:
         ios.flags(f);
     }
 
-    IosFlagSaver(const IosFlagSaver &rhs) = delete;
-    IosFlagSaver& operator= (const IosFlagSaver& rhs) = delete;
+    //IosFlagSaver(const IosFlagSaver &rhs) = delete;
+    //IosFlagSaver& operator= (const IosFlagSaver& rhs) = delete;
 
 private:
+    IosFlagSaver(const IosFlagSaver &rhs); // disable copy contructore
+    IosFlagSaver& operator= (const IosFlagSaver& rhs); // old way
+
     std::ostream& ios;
     std::ios::fmtflags f;
 };



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/5cc54458b71eaf9878f9b78b3bd3d99cd3e19251

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/5cc54458b71eaf9878f9b78b3bd3d99cd3e19251
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231014/f90e26bf/attachment-0001.htm>
