From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:58:11 +0000 (UTC)
Subject: master - WHATS_NEW: config/profile_dir
Message-ID: <20130702135811.3853960E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd94dd3b7e9e55029dd79274da18d8503fa12ebf
Commit:        fd94dd3b7e9e55029dd79274da18d8503fa12ebf
Parent:        7ce0c6777b88f9a20aa1c4476f37fdc37d7732cd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 2 15:57:46 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:57:46 2013 +0200

WHATS_NEW: config/profile_dir

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 37e5534..b68360f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -7,6 +7,7 @@ Version 2.02.99 -
   Support changing VG/LV profiles: vgchange/lvchange --profile/--detachprofile.
   Support storing profile name in metadata for both VGs and LVs.
   Add new --profile command line arg to select a configuration profile for use.
+  Add config/profile_dir to set working directory to load profiles from.
   Add configure --with-default-profile-subdir to select dir to keep profiles in.
   Add support for configuration profiles.
   Introduce config_source wrapper for identification of configuration sources.


