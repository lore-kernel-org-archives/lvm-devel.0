From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:51:35 +0000 (UTC)
Subject: master - WHATS_NEW: configuration profile support
Message-ID: <20130702135135.7BE9260FCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ce0c6777b88f9a20aa1c4476f37fdc37d7732cd
Commit:        7ce0c6777b88f9a20aa1c4476f37fdc37d7732cd
Parent:        9f6cfc9de497944b60a0b52e77ff532c489bce63
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 2 15:51:21 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:51:21 2013 +0200

WHATS_NEW: configuration profile support

---
 WHATS_NEW |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b501121..37e5534 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,15 @@
 Version 2.02.99 - 
 ===================================
+  Add vgs/lvs -o vg_profile/lv_profile to report profiles attached to VG/LV.
+  Add default.profile configuration profile and install it on make install.
+  Create a new 'conf' subdir for configuration files including profiles.
+  Make selected thinp settings customizable by a profile.
+  Support changing VG/LV profiles: vgchange/lvchange --profile/--detachprofile.
+  Support storing profile name in metadata for both VGs and LVs.
+  Add new --profile command line arg to select a configuration profile for use.
+  Add configure --with-default-profile-subdir to select dir to keep profiles in.
+  Add support for configuration profiles.
+  Introduce config_source wrapper for identification of configuration sources.
   Avoid creation of multiple archives for one command.
   Use mirror_segtype_default if type not specified for linear->mirror upconvert.
   Fix use of too big chunks of memory when communication with lvmetad.


