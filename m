From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Apr 2016 12:56:34 +0000 (UTC)
Subject: master - udev: rules: remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0)
Message-ID: <20160425125634.B0B8D61BF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bb33aaf556134b0217b822755383245ac678527
Commit:        2bb33aaf556134b0217b822755383245ac678527
Parent:        379874a2d0ff51cdbfbc1cc723b41e06bcdfd277
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Apr 25 14:48:46 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Apr 25 14:55:54 2016 +0200

udev: rules: remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0)

Multipath 0.6.0 contains new 11-dm-mpath.rules which supersede the rule
that was in 10-dm.rules. The 11-dm-mpath.rules are also more complete,
fixing several other issues. Using the new 11-dm-mpath.rules from
multipath-tools >= 0.6.0 is strongly recommended for proper
DM multipath functionality!

See also:
  http://christophe.varoqui.free.fr
  http://git.opensvc.com/gitweb.cgi?p=multipath-tools/.git;a=blob;f=multipath/11-dm-mpath.rules
---
 WHATS_NEW           |    1 +
 udev/10-dm.rules.in |    4 ----
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 961bae7..1aa335e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0).
 
 Version 2.02.151 - 23rd April 2016
 ==================================
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 2755530..8d7a8ca 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -120,10 +120,6 @@ ENV{DM_UDEV_RULES_VSN}="2"
 
 ENV{DM_UDEV_DISABLE_DM_RULES_FLAG}!="1", ENV{DM_NAME}=="?*", SYMLINK+="(DM_DIR)/$env{DM_NAME}"
 
-# We have to ignore further rule application for inappropriate events
-# and devices. But still send the notification if cookie exists.
-ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_disable"
-
 # Avoid processing and scanning a DM device in the other (foreign)
 # rules if it is in suspended state. However, we still keep 'disk'
 # and 'DM subsystem' related rules enabled in this case.


