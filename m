From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 29 Oct 2013 12:34:44 +0000 (UTC)
Subject: master - udev: proper reset of DM_UDEV_DISABLE_OTHER_RULES_FLAG and honour this flag in lvmetad rules
Message-ID: <20131029123444.19D0660FCB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d0621267d644d21d3c1ad3a5268af0ef3d7eb9a
Commit:        9d0621267d644d21d3c1ad3a5268af0ef3d7eb9a
Parent:        f3a6f7073b4ca71dcc0360daa66a845490b76893
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 29 13:15:45 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 29 13:31:00 2013 +0100

udev: proper reset of DM_UDEV_DISABLE_OTHER_RULES_FLAG and honour this flag in lvmetad rules

Reset the DM_UDEV_OTHER_RULES_FLAG to original value right at the
time of dropping the DM_NOSCAN flag.

When DM_NOSCAN is set, the DM_UDEV_DISABLE_OTHER_RULES_FLAG is also set
to avoid udev processing in "other/foreign" rules. If the noscan flag
is dropped, the DM_UDEV_DISABLE_OTHER_RULES_FLAG should be reset to
its original value.

Also, lvmetad should respect the DM_UDEV_DISABLE_OTHER_RULES_FLAG
because if the volume is set with this flag it:
  - definitely is not a top-level device (so makes no sense for lvmetad scanning)
  - is not supposed to be scanned further (for any stacking on top of
    it, including LVM stacking itself and any autoactivation of stacked LVs)
---
 udev/11-dm-lvm.rules.in       |    2 +-
 udev/69-dm-lvm-metad.rules.in |    1 +
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/udev/11-dm-lvm.rules.in b/udev/11-dm-lvm.rules.in
index 5032280..9ca0375 100644
--- a/udev/11-dm-lvm.rules.in
+++ b/udev/11-dm-lvm.rules.in
@@ -32,7 +32,7 @@ IMPORT{program}="(DM_EXEC)/dmsetup splitname --nameprefixes --noheadings --rows
 # uevent that follows for this LV, even an artificially generated one).
 ENV{DM_SUBSYSTEM_UDEV_FLAG0}=="1", ENV{DM_NOSCAN}="1", ENV{DM_DISABLE_OTHER_RULES_FLAG_OLD}="$env{DM_UDEV_DISABLE_OTHER_RULES_FLAG}", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="1"
 ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", IMPORT{db}="DM_NOSCAN", IMPORT{db}="DM_DISABLE_OTHER_RULES_FLAG_OLD"
-ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="$env{DM_DISABLE_OTHER_RULES_FLAG_OLD}", \
+ENV{DM_SUBSYSTEM_UDEV_FLAG0}!="1", ENV{DM_NOSCAN}=="1", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="$env{DM_DISABLE_OTHER_RULES_FLAG_OLD}", \
 				   ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG_OLD}="", ENV{DM_NOSCAN}=""
 
 ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 3e303b1..34441ab 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -18,6 +18,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
 ENV{DM_NOSCAN}=="1", GOTO="lvm_end"
+ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="lvm_end"
 
 # If the PV label got lost, inform lvmetad immediately.
 # Detect the lost PV label by comparing previous ID_FS_TYPE value with current one.


