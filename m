From: David Teigland <teigland@sourceware.org>
Date: Mon, 18 Sep 2017 11:58:23 -0400
Subject: master - man pvscan: just write --activate in description
Message-ID: <201709181558.v8IFwNpx006867@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=200793edc681ac956e9341af6b5f20dc4e3f9ee8
Commit:        200793edc681ac956e9341af6b5f20dc4e3f9ee8
Parent:        d73eddcdc02420793c2287b6aa184dc8eb2dcef4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 18 10:56:39 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 18 10:56:39 2017 -0500

man pvscan: just write --activate in description

rather than -a|--activate, because web pages on
man7.org are not printing the | character.
---
 man/pvscan.8_des |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index d6b554e..c3d80b4 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -64,8 +64,7 @@ When event-driven system services detect a new LVM device, the first step
 is to automatically scan and cache the metadata from the device.  This is
 done by pvscan --cache.  A second step is to automatically activate LVs
 that are present on the new device.  This auto-activation is done by the
-same pvscan --cache command when the option '-a|--activate ay' is
-included.
+same pvscan --cache command when the option --activate ay is included.
 
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
@@ -80,11 +79,11 @@ When this setting is undefined, all LVs are auto-activated (when lvm is
 fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|--activate is needed.
+vgchange or lvchange --activate is needed.
 .IP \[bu] 2
 pvscan auto-activation can be only done in combination with --cache.
 .IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+Auto-activation is designated by the "a" argument in --activate ay.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.


