From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:49 +0000 (UTC)
Subject: dev-mornfall-lvmcache - udev: add a few comments about variables used to recognize events
Message-ID: <20130605120249.1641B60993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baf9ef2047675279c72f27abeb2c328f5de2c78d
Commit:        baf9ef2047675279c72f27abeb2c328f5de2c78d
Parent:        f39f5b86c3f94fe83744054012d6d8b33bb7d7a0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 3 11:01:57 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 3 11:01:57 2013 +0200

udev: add a few comments about variables used to recognize events

---
 udev/10-dm.rules.in |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 512d156..3a157d5 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -77,11 +77,29 @@ LABEL="dm_flags_done"
 # before (e.g. in initrd). If udev is used in initrd, we require the udev init
 # script to not remove the existing udev database so we can reuse the information
 # stored at the time of device activation in the initrd.
+# The DM_ACTIVATION variable tells when any device stacked above should be
+# (re)activated as well.
 ACTION!="add", GOTO="dm_no_coldplug"
 ENV{DM_UDEV_RULES_VSN}!="1", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"
 ENV{DM_ACTIVATION}="1"
 LABEL="dm_no_coldplug"
 
+# Putting it together, following table is used to recognize genuine and spurious events.
+# N.B. Spurious events are generated based on use of the WATCH udev
+# rule or by triggering an event manually by "udevadm trigger" call
+# or by "echo <event_name> > /sys/block/dm-X/uevent".
+#
+#        EVENT              DM_UDEV_PRIMARY_SOURCE_FLAG   DM_ACTIVATION
+# ======================================================================
+# add event (genuine)                  0                        0
+# change event (genuine)               1                        1
+# add event (spurious)
+#   |_ dev still not active            0                        0
+#   \_ dev already active              1                        1
+# change event (spurious)
+#   |_ dev still not active            0                        0
+#   \_ dev already active              1                        0
+
 # "dm" sysfs subdirectory is available in newer versions of DM
 # only (kernels >= 2.6.29). We have to check for its existence
 # and use dmsetup tool instead to get the DM name, uuid and 


