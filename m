From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Wed, 18 Oct 2023 09:37:29 +0000
Subject: [Git][csonto/lvm2][main] packit: Add packit configuration
Message-ID: <652fa7593eadb_2c98caf381014f0@gitlab-sidekiq-low-urgency-cpu-bound-v2-6dfc54d567-hh59c.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at Marian Csontos / lvm2


Commits:
1e5ca375 by Marian Csontos at 2023-10-18T11:36:58+02:00
packit: Add packit configuration

- - - - -


1 changed file:

- + .packit.yaml


Changes:

=====================================
.packit.yaml
=====================================
@@ -0,0 +1,152 @@
+# See the documentation for more information:
+# https://packit.dev/docs/configuration/
+
+# name in upstream package repository or registry (e.g. in PyPI)
+upstream_package_name: lvm2
+# downstream (Fedora) RPM package name
+downstream_package_name: lvm2
+
+specfile_path: spec/lvm2.spec
+
+# add or remove files that should be synced
+files_to_sync:
+    - spec/lvm2.spec
+    - spec/macros.inc
+    - spec/source.inc
+    - spec/build.inc
+    - spec/packages.inc
+    #- .packit.yaml
+
+actions:
+
+  get-current-version: "sed -e 's/^\\([0-9.]*\\).*/\\1/' VERSION"
+
+  # NOTE: make dist does not fit, it needs ./configure which would require dependencies installed
+  # NOTE: Must use semicolons and cannot use comments here - the lines are joined into single string.
+  create-archive: >
+    bash -c 'set -xv;
+    PREFIX=LVM2.$PACKIT_PROJECT_VERSION;
+    TARBALL=spec/$PREFIX.tgz;
+    git archive --prefix=$PREFIX/ --output=$TARBALL HEAD > /dev/null;
+    echo $TARBALL;
+    '
+
+  # fix-spec-file:
+  # - It updates Version and Release in the spec file.
+  # - In lvm2 case it needs to update device_mapper_version
+  # The following is not needed as we use same name as our spec files:
+  # - It replaces Source configured by spec_source_id (default Source0) with a local path to the generated archive.
+  # - It changes the first %setup (or %autosetup) macro in %prep and adds -n so
+  #   the generated tarball can be unpacked (it tries to extract the directory name
+  #   directly from the archive or uses the configured archive_root_dir_template).
+  fix-spec-file: >
+    bash -c 'set -xv;
+    VERSION_DM=$(sed -e "s/^\([0-9.]*\).*/\1/" VERSION_DM);
+    VERSION=$(sed -e "s/^\([0-9.]*\).*/\1/" VERSION);
+    echo PACKIT_PROJECT_VERSION="$PACKIT_PROJECT_VERSION" >&2;
+    echo PACKIT_RPMSPEC_RELEASE="$PACKIT_RPMSPEC_RELEASE" >&2;
+    sed -i spec/source.inc
+    -e "s/\(^\s*%global\s*device_mapper_version\s*\).*/\1$VERSION_DM/"
+    -e "s/\(^\s*Version:\s*\).*/\1$VERSION/"
+    -e "s/\(^\s*Release:\s*\).*/\10.$PACKIT_RPMSPEC_RELEASE/"
+    -e "s/\(^\s*Source0:\s*\).*/\1LVM2.$VERSION.tgz/"
+    # NOTE: Reamining is not needed when using LVM2.${VERSION} :-)
+    #sed -i spec/lvm2.spec 
+    #-e "s/^\s*%\(auto\|\)setup\s*.*/%setup -q -n lvm2-$VERSION/";
+    '
+  #  - "bash -c 'sed -i spec/lvm2.spec -e \"s/Version:.*/Version: $(sed -e \"s/^\\([0-9.]*\\).*/\\1/\" VERSION)/\"'"
+  # fix-spec-file:
+  #  - bash -c "sed -i spec/lvm2.spec -e \"s/%global device_mapper_version .*/%global device_mapper_version $(sed -e 's/^\\([0-9.]*\\).*/\\1/' VERSION_DM)/\""
+  #  # NOTE: Even though there is get-current-version hook, the version is not used in Version: in spec
+  #  - "bash -c 'sed -i spec/lvm2.spec -e \"s/Version:.*/Version: $(sed -e \"s/^\\([0-9.]*\\).*/\\1/\" VERSION)/\"'"
+
+# TODO:
+# - COPR build of latest version for all fedoras and cXs
+# - fedora PR for a release
+# - release - tag
+#     - build for epel-8, epel-9, fedora-all
+jobs:
+- job: copr_build
+  trigger: pull_request
+  metadata:
+    targets:
+    - fedora-rawhide-x86_64
+
+- job: copr_build
+  trigger: commit
+  metadata:
+    branch: main
+    targets:
+    - fedora-rawhide-x86_64
+
+- job: copr_build
+  trigger: commit
+  metadata:
+    branch: latest
+    targets:
+    - fedora-rawhide-x86_64
+
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
+- job: copr_build
+  trigger: release
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
+  metadata:
+    targets:
+      - fedora-all
+      - epel-7
+      - epel-8
+      - epel-9
+



View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/1e5ca3758eed36f4d79e79b02d8dd070073b3ccf

-- 
View it on GitLab: https://gitlab.com/csonto/lvm2/-/commit/1e5ca3758eed36f4d79e79b02d8dd070073b3ccf
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231018/0129ef9b/attachment-0001.htm>
