From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 11:12:14 +0000 (UTC)
Subject: master - man: dmsetup
Message-ID: <20160121111214.ADE8960E28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=640c45d5a4da1a1cedf47b5a7f27b05e1fd00d76
Commit:        640c45d5a4da1a1cedf47b5a7f27b05e1fd00d76
Parent:        43b436398ec81c8d0a2dbd2062ce864997d22f26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 11:36:26 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 12:10:26 2016 +0100

man: dmsetup

Typo in CMD_UDEVCREATECOOKIE macro name noticed by rpmlint.
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e5480e1..df3613b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.115 -
 =====================================
+  Fix man page for dmsetup udevcreatecookie.
 
 Version 1.02.114 - 14th December 2015
 =====================================
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 183f4fc..f92dbe5 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -309,10 +309,10 @@ dmsetup \(em low level logical volume management
 .
 .HP
 .B dmsetup
-.de CMD_UDEVCTEATECOOKIE
+.de CMD_UDEVCREATECOOKIE
 .  BR udevcreatecookie
 ..
-.CMD_UDEVCTEATECOOKIE
+.CMD_UDEVCREATECOOKIE
 .
 .HP
 .B dmsetup


