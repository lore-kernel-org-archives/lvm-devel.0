From: David Teigland <teigland@sourceware.org>
Date: Thu, 28 Feb 2019 09:52:54 -0500
Subject: master - pvscan service: use StartLimitIntervalSec
Message-ID: <201902281452.x1SEqsgJ026971@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce79b62bc2fcaddf65e090ec3fef75926cddf82c
Commit:        ce79b62bc2fcaddf65e090ec3fef75926cddf82c
Parent:        a9eaab6bebe1919b476ec3a4d094a4d6c512920e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 28 08:50:37 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 28 08:50:37 2019 -0600

pvscan service: use StartLimitIntervalSec

systemd changed the name
---
 scripts/lvm2-pvscan.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2-pvscan.service.in b/scripts/lvm2-pvscan.service.in
index 93fe062..09753e8 100644
--- a/scripts/lvm2-pvscan.service.in
+++ b/scripts/lvm2-pvscan.service.in
@@ -2,7 +2,7 @@
 Description=LVM event activation on device %i
 Documentation=man:pvscan(8)
 DefaultDependencies=no
-StartLimitInterval=0
+StartLimitIntervalSec=0
 BindsTo=dev-block-%i.device
 Before=shutdown.target
 Conflicts=shutdown.target


