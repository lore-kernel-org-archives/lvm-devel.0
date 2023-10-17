From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Tue, 17 Oct 2023 20:43:23 +0000
Subject: [Git][csonto/lvm2][main] Update .gitlab-ci.yml file
Message-ID: <652ef1eb4d4f9_2c3abd0bc289e3@gitlab-sidekiq-low-urgency-cpu-bound-v2-65f69dcbf-g5mxm.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at Marian Csontos / lvm2


Commits:
1af15be9 by Marian Csontos at 2023-10-17T20:43:09+00:00
Update .gitlab-ci.yml file
- - - - -


1 changed file:

- .gitlab-ci.yml


Changes:

=====================================
.gitlab-ci.yml
=====================================
@@ -66,12 +66,15 @@ test-job:
       --with-integrity=internal
       --disable-silent-rules
     - make
-    - rm -rf test/results || :
+    - >
+      rm -rf test/results || :
     - mkdir -p /dev/shm/lvm2-test
     - mount -o remount,dev /dev/shm
     # TODO: Disable services and setup lvm.conf:
-    - sed -i -e 's/^\( *\)#* *\(monitoring\) *= *.*/\1\2 = 0/' /etc/lvm/lvm.conf || :
-    - sed -i -e 's/^\( *\)#* *\(event_activation\) *= *.*/\1\2 = 0/' /etc/lvm/lvm.conf || :
+    - >
+      sed -i -e 's/^\( *\)#* *\(monitoring\) *= *.*/\1\2 = 0/' /etc/lvm/lvm.conf || :
+    - >
+      sed -i -e 's/^\( *\)#* *\(event_activation\) *= *.*/\1\2 = 0/' /etc/lvm/lvm.conf || :
     # TODO: Need to distinguish failed test from failed harness
     # TODO: Also need a way to find if run is incomplete, e.g. full disk resulting in many skipped tests
     - VERBOSE=0 BATCH=1 LVM_TEST_DIR=/dev/shm/lvm2-test make check || true



View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/1af15be9ae990b4d0465b5ff31bd0ce332700873

-- 
View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/1af15be9ae990b4d0465b5ff31bd0ce332700873
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231017/9e83dabb/attachment-0001.htm>
