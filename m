From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Mon, 10 Jul 2023 14:28:26 +0000
Subject: [Git][csonto/lvm2][main] [WIP] Add .gitlab-ci.yml
Message-ID: <64ac158a981_28a18ec138a5@gitlab-sidekiq-low-urgency-cpu-bound-v2-6db7747954-m5nph.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at Marian Csontos / lvm2


Commits:
54f0268b by Marian Csontos at 2023-07-10T16:27:57+02:00
[WIP] Add .gitlab-ci.yml

- - - - -


1 changed file:

- + .gitlab-ci.yml


Changes:

=====================================
.gitlab-ci.yml
=====================================
@@ -0,0 +1,86 @@
+stages:
+  - approve
+  - test
+
+approve1:
+  stage: approve
+  script:
+    - echo "Approved..."
+  rules:
+    # TODO: Filter only safe repositories, or user in developers
+    - if: $CI_PROJECT_PATH != "csonto/lvm2" && $CI_PROJECT_PATH != "lvmteam/lvm2"
+      when: manual
+    # TODO: for other branches than main/rhel: run pipeline only when requested:
+    - if: $CI_COMMIT_BRANCH != "main" && $CI_COMMIT_BRANCH !~ "^rhel.*"
+      when: manual
+    - when: on_success
+  allow_failure: false
+
+# TODO:
+# - check results of autoreconf and make generate - may need additional commit
+#     - we need a particular setup (rawhide OR latest supported fedora?)
+# - do make rpm and publish results as artifacts - we will use packit/COPR for this eventually
+
+# Run on any commits to main (master), rhel8, rhel9 branches
+test-job:
+  stage: test
+  parallel:
+    matrix:
+      - TAG: rhel8
+        CONFIGURE: >
+          --with-cluster=internal
+          --enable-cmirrord
+      - TAG: rhel9
+        CONFIGURE: >
+          --with-default-use-devices-file=1
+          --enable-app-machineid
+          --enable-editline
+          --disable-readline
+  artifacts:
+    paths:
+      - test/results/
+    expire_in: 1 week
+  tags:
+      - ${TAG}
+  script:
+    # Common options go here, diffs to the above matrix
+    - >
+      ./configure ${CONFIGURE}
+      --enable-fsadm
+      --enable-write_install
+      --enable-pkgconfig
+      --enable-cmdlib
+      --enable-dmeventd
+      --enable-blkid_wiping
+      --enable-udev_sync
+      --with-thin=internal
+      --with-cache=internal
+      --enable-lvmpolld
+      --enable-lvmlockd-dlm --enable-lvmlockd-dlmcontrol
+      --enable-lvmlockd-sanlock
+      --enable-dbus-service --enable-notify-dbus
+      --enable-dmfilemapd
+      --with-writecache=internal
+      --with-vdo=internal --with-vdo-format=/usr/bin/vdoformat
+      --with-integrity=internal
+      --disable-silent-rules
+    - make
+    - rm -rf test/results
+    - mkdir -p /dev/shm/lvm2-test
+    - mount -o remount,dev /dev/shm
+    # TODO: Need to distinguish failed test from failed harness
+    # TODO: Also need a way to find if run is incomplete, e.g. full disk resulting in many skipped tests
+    - VERBOSE=0 BATCH=1 LVM_TEST_DIR=/dev/shm/lvm2-test make check || true
+    - rm -rf /dev/shm/lvm2-test
+    - cut -d' ' -f2 test/results/list | sort | uniq -c
+    # Filter artifacts - keep only logs from tests which are not pass
+    - cd test/results && rm $(grep 'passed$' list | cut -d' ' -f1 | sed -e 's|/|_|g' -e 's|.*|\0.txt|')
+    # TODO: Keep a list of known failures, and translate into regexp - or simply use python...
+    - if grep failed test/results/list | grep -v '\\\(dbustest\|lvconvert-mirror\)\.sh' | sort; then false; else true; fi
+  rules:
+    # Filter only safe repositories, or user in developers:
+    # NOTE: Already done in approve stage, may be more caution than necessary
+    - if: $CI_PROJECT_PATH != "csonto/lvm2" && $CI_PROJECT_PATH != "lvmteam/lvm2"
+      when: manual
+    - when: on_success
+



View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/54f0268ba41409880cbe931dce5adcb680c39a09

-- 
View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/54f0268ba41409880cbe931dce5adcb680c39a09
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230710/7c3d0eea/attachment-0001.htm>
