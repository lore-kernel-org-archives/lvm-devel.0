From: mwilck@suse.com <mwilck@suse.com>
Date: Thu, 17 Feb 2022 15:58:29 +0100
Subject: [PATCH v2] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
Message-ID: <20220217145829.19227-1-mwilck@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Martin Wilck <mwilck@suse.com>

device-mapper sets the flag DM_UDEV_DISABLE_OTHER_RULES_FLAG to 1 for
devices which are unusable. They may be no set up yet, suspended, or
otherwise unusable (e.g. multipath maps without usable path). This
flag does not necessarily imply SYSTEMD_READY=0 and must therefore
be tested separately.

Signed-off-by: Martin Wilck <mwilck@suse.com>

---
Changes in v2:
 - Moved the check further up; DM_UDEV_DISABLE_OTHER_RULES_FLAG must
   be checked before ID_FS_TYPE to be effective

---
 udev-md-raid-assembly.rules | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/udev-md-raid-assembly.rules b/udev-md-raid-assembly.rules
index d668cdd..bc9679f 100644
--- a/udev-md-raid-assembly.rules
+++ b/udev-md-raid-assembly.rules
@@ -9,6 +9,9 @@ SUBSYSTEM!="block", GOTO="md_inc_end"
 
 # skip non-initialized devices
 ENV{SYSTEMD_READY}=="0", GOTO="md_inc_end"
+# device mapper sets DM_UDEV_DISABLE_OTHER_RULES_FLAG for devices which
+# aren't ready to use
+KERNEL=="dm-*", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="md_inc_end"
 
 # handle potential components of arrays (the ones supported by md)
 ENV{ID_FS_TYPE}=="linux_raid_member", GOTO="md_inc"
-- 
2.35.1



