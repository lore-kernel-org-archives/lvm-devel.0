From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Sep 2013 10:48:31 +0000 (UTC)
Subject: master - udev: override new udev default timeout of 30s to original 3min
Message-ID: <20130911104831.E3E9C60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72a9d4f879751d58e531efbffaef1f7d325092c7
Commit:        72a9d4f879751d58e531efbffaef1f7d325092c7
Parent:        2691f1d764182722195cda80be1f511e968480aa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 11 12:42:29 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 11 12:47:38 2013 +0200

udev: override new udev default timeout of 30s to original 3min

New versions of udev changed the default event timeout to 30s
from original 3min. This causes problems with LVM processes that
starve because of the IO load caused by some LVM actions (e.g.
mirror/raid synchronization).

Reinstate the 3min udev timeout for now until we optimize this
in a way that even the 30s timeout is sufficient.
---
 udev/11-dm-lvm.rules.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index 58ef210..90804f3 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -29,6 +29,8 @@ ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"
 # Create symlinks for top-level devices only.
 ENV{DM_VG_NAME}=="?*", ENV{DM_LV_NAME}=="?*", SYMLINK+="$env{DM_VG_NAME}/$env{DM_LV_NAME}", GOTO="lvm_end"
 
+OPTIONS+="event_timeout=180"
+
 LABEL="lvm_disable"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}="1"
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"


