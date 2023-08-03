From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Thu, 03 Aug 2023 09:00:51 +0000
Subject: [Git][lvmteam/lvm2][main] 4 commits: WHATS_NEW: update
Message-ID: <64cb6cc359974_28a799038015@gitlab-sidekiq-low-urgency-cpu-bound-v2-69d5f7fd7b-99s85.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at LVM team / lvm2


Commits:
1fe2a749 by Marian Csontos at 2023-08-02T14:38:23+02:00
WHATS_NEW: update

- - - - -
016e469c by Marian Csontos at 2023-08-02T14:41:12+02:00
pre-release

- - - - -
606ecae5 by Marian Csontos at 2023-08-02T14:42:16+02:00
post-release

- - - - -
abdb87dd by Marian Csontos at 2023-08-03T11:00:23+02:00
CI: Add .gitlab-ci.yml

- - - - -


5 changed files:

- + .gitlab-ci.yml
- VERSION
- VERSION_DM
- WHATS_NEW
- WHATS_NEW_DM


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


=====================================
VERSION
=====================================
@@ -1 +1 @@
-2.03.22(2)-git (2023-04-21)
+2.03.23(2)-git (2023-08-02)


=====================================
VERSION_DM
=====================================
@@ -1 +1 @@
-1.02.196-git (2023-04-21)
+1.02.197-git (2023-08-02)


=====================================
WHATS_NEW
=====================================
@@ -1,6 +1,10 @@
-version 2.03.22 - 
-=================================
+version 2.03.23 - 
+==================================
+
+version 2.03.22 - 02nd August 2023
+==================================
   Fix pv_major/pv_minor report field types so they are integers, not strings.
+  Add lvmdevices --delnotfound to delete entries for missing devices.
   Always use cachepool name for metadata backup LV for lvconvert --repair.
   Make metadata backup LVs read-only after pool's lvconvert --repair.
   Improve VDO and Thin support with lvmlockd.
@@ -14,9 +18,13 @@ version 2.03.22 -
   Resize COW above trimmed maximal size is does not return error.
   Support parsing of vdo geometry format version 4.
   Add lvm.conf thin_restore and cache_restore settings.
+  Handle multiple mounts while resizing volume with a FS.
+  Handle leading/trailing spaces in sys_wwid and sys_serial used by deivce_id.
   Enhance lvm_import_vdo and use snapshot when converting VDO volume.
-  Fix parsed of VDO metadata.
+  Fix parsing of VDO metadata.
   Fix failing -S|--select for non-reporting cmds if using LV info/status fields.
+  Allow snapshots of raid+integrity LV.
+  Fix multisegment RAID1 allocator to prevent using single disk for more legs.
 
 version 2.03.21 - 21st April 2023
 =================================


=====================================
WHATS_NEW_DM
=====================================
@@ -1,5 +1,8 @@
-Version 1.02.196 - 
-==================================
+Version 1.02.197 - 
+===================================
+
+Version 1.02.196 - 02nd August 2023
+===================================
 
 Version 1.02.195 - 21st April 2023
 ==================================



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/9385bea57187080cbee2d19e4c7b7fe2e8af6e4a...abdb87dd23b6b120471edd7927fb6a7fc912b16b

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/9385bea57187080cbee2d19e4c7b7fe2e8af6e4a...abdb87dd23b6b120471edd7927fb6a7fc912b16b
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230803/12ebf915/attachment-0001.htm>
