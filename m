From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 22 Jan 2014 14:21:23 +0000 (UTC)
Subject: master - udev: drop cryptsetup specific rules from 10-dm.rules
Message-ID: <20140122142123.0FD9C6011F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36a09cf463b68cc56330db43d44e02932c12251b
Commit:        36a09cf463b68cc56330db43d44e02932c12251b
Parent:        d2956f0a594c0522de925ab3ca47a56a5a09a2c7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 22 15:15:02 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 22 15:18:57 2014 +0100

udev: drop cryptsetup specific rules from 10-dm.rules

These udev flags are set directly in cryptsetup for some
time now so there's no need to have it in our rules then.

See also:
https://code.google.com/p/cryptsetup/source/detail?spec=svn4f14b43a3d3e7310465005c401f37e19f8cb85e6&r=4f14b43a3d3e7310465005c401f37e19f8cb85e6
---
 WHATS_NEW_DM        |    1 +
 udev/10-dm.rules.in |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 448a7f0..40c371b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Drop cryptsetup specific rules from 10-dm.rules - cryptsetup sets them.
 
 Version 1.02.84 - 20th January 2014
 ===================================
diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index f7088f1..2755530 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -123,8 +123,6 @@ ENV{DM_UDEV_DISABLE_DM_RULES_FLAG}!="1", ENV{DM_NAME}=="?*", SYMLINK+="(DM_DIR)/
 # We have to ignore further rule application for inappropriate events
 # and devices. But still send the notification if cookie exists.
 ENV{DM_UUID}=="mpath-?*", ENV{DM_ACTION}=="PATH_FAILED", GOTO="dm_disable"
-ENV{DM_UUID}=="CRYPT-TEMP-?*", GOTO="dm_disable"
-ENV{DM_UUID}!="?*", ENV{DM_NAME}=="temporary-cryptsetup-?*", GOTO="dm_disable"
 
 # Avoid processing and scanning a DM device in the other (foreign)
 # rules if it is in suspended state. However, we still keep 'disk'


