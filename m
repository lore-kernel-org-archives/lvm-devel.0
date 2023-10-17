From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Tue, 17 Oct 2023 20:36:02 +0000
Subject: [Git][csonto/lvm2][main] packit: Add build for latest branch
Message-ID: <652ef0329c5c3_2c99c3c97951@gitlab-sidekiq-low-urgency-cpu-bound-v2-65f69dcbf-jrfhs.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at Marian Csontos / lvm2


Commits:
bb45b2fb by Marian Csontos at 2023-10-17T22:35:30+02:00
packit: Add build for latest branch

- - - - -


1 changed file:

- .packit.yaml


Changes:

=====================================
.packit.yaml
=====================================
@@ -86,6 +86,37 @@ jobs:
     targets:
     - fedora-rawhide-x86_64
 
+- job: copr_build
+  trigger: commit
+  metadata:
+    branch: latest
+    targets:
+    - fedora-rawhide-x86_64
+    - fedora-all
+  specfile_path: spec/fedora/lvm2.spec
+  actions:
+    create-archive: >
+      bash -c 'set -xv;
+      PREFIX=LVM2.$PACKIT_PROJECT_VERSION;
+      TARBALL=spec/fedora/$PREFIX.tgz;
+      git archive --prefix=$PREFIX/ --output=$TARBALL HEAD > /dev/null;
+      echo $TARBALL;
+      '
+    # TODO: Release should be taken from tag
+    fix-spec-file: >
+      bash -c 'set -xv;
+      VERSION_DM=$(sed -e "s/^\([0-9.]*\).*/\1/" VERSION_DM);
+      VERSION=$(sed -e "s/^\([0-9.]*\).*/\1/" VERSION);
+      RELEASE=$(sed -e "s/^.*-\([0-9]*\) ([-0-9]*])//" VERSION);
+      echo PACKIT_PROJECT_VERSION="$PACKIT_PROJECT_VERSION" >&2;
+      echo PACKIT_RPMSPEC_RELEASE="$PACKIT_RPMSPEC_RELEASE" >&2;
+      sed -i spec/fedora/lvm2.spec
+      -e "s/\(^\s*%global\s*device_mapper_version\s*\).*/\1$VERSION_DM/"
+      -e "s/\(^\s*Version:\s*\).*/\1$VERSION/"
+      -e "s/\(^\s*Release:\s*\).*/\10.$PACKIT_RPMSPEC_RELEASE/"
+      -e "s/\(^\s*Source0:\s*\).*/\1LVM2.$VERSION.tgz/"
+      '
+
 - job: copr_build
   trigger: release
   specfile_path: spec/fedora/lvm2.spec



View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/bb45b2fb02c1d50c907a840d641dc49ff9cfaa74

-- 
View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/bb45b2fb02c1d50c907a840d641dc49ff9cfaa74
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231017/343904db/attachment-0001.htm>
