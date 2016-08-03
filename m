From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  3 Aug 2016 20:49:57 +0000 (UTC)
Subject: master - man: minor corrections in pvscan
Message-ID: <20160803204957.0CC1760B3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be497175e03b5cb51f2972a84528216bba06412a
Commit:        be497175e03b5cb51f2972a84528216bba06412a
Parent:        2b01dca28aca71af1388e96d4ed3627d352d9399
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 3 15:49:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 3 15:49:43 2016 -0500

man: minor corrections in pvscan

---
 man/pvscan.8.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 38f424f..5ff5fa5 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -79,7 +79,7 @@ When given specific device name arguments, pvscan \-\-cache will only
 read the named devices.
 
 .IP \[bu] 2
-LVM udev rules and systemd services are used to intiate automatic device
+LVM udev rules and systemd services are used to initiate automatic device
 scanning.
 
 .IP \[bu] 2
@@ -99,8 +99,8 @@ if the global_filter has changed, then all devices must be rescanned
 for metadata with the command pvscan \-\-cache.
 
 .IP \[bu] 2
-lvmetad ignores older metadata formats, e.g. lvm1, and should not be
-used if they exist.
+lvmetad does not cache older metadata formats, e.g. lvm1, and will
+be temporarily disabled if they are seen.
 
 .IP \[bu] 2
 To notify lvmetad about a device that is no longer present, the major and


