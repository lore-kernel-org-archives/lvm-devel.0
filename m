From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Mar 2020 19:42:56 +0000 (GMT)
Subject: master - man: lvm2-activation-generator fix vgchange comment
Message-ID: <20200310194256.A0FF8395A078@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbdcc45255497e2f926ac28ba33aa819d53f5c7c
Commit:        fbdcc45255497e2f926ac28ba33aa819d53f5c7c
Parent:        dd0fdd846d85d7028e65bb801c27791a8e2cee2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 10 14:41:51 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 10 14:41:51 2020 -0500

man: lvm2-activation-generator fix vgchange comment

generated services use vgchange -aay (not -ay)
---
 man/lvm2-activation-generator.8_main | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
index ba7fd0dda..478c23bd5 100644
--- a/man/lvm2-activation-generator.8_main
+++ b/man/lvm2-activation-generator.8_main
@@ -9,7 +9,7 @@ lvm2-activation-generator - generator for systemd units to activate LVM volumes
 The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot to
 generate systemd units at runtime to activate LVM Logical Volumes (LVs)
 when global/event_activation=0 is set in \fBlvm.conf\fP(5).  These units use
-\fBvgchange -ay\fP to activate LVs.
+\fBvgchange -aay\fP to activate LVs.
 
 If event_activation=1, the lvm2-activation-generator exits immediately without
 generating any systemd units, and LVM fully relies on event-based



