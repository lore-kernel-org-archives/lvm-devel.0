From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:17 +0000 (UTC)
Subject: master - dmsetup: fix udev warning message
Message-ID: <20120823124217.0EDDDA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9ae22d758e6b5eed62774f5b2a71b87d818087e
Commit:        b9ae22d758e6b5eed62774f5b2a71b87d818087e
Parent:        7e318dad427c7d2e6787f9412cf7c4ee761faf9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 28 21:32:24 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:36:12 2012 +0200

dmsetup: fix udev warning message

Configure option is --enable-udev_sync.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 7a632c7..ca1087d 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -977,7 +977,7 @@ static int _udevcomplete(CMD_ARGS)
 }
 
 #ifndef UDEV_SYNC_SUPPORT
-static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev-sync\" to enable.";
+static const char _cmd_not_supported[] = "Command not supported. Recompile with \"--enable-udev_sync\" to enable.";
 
 static int _udevcreatecookie(CMD_ARGS)
 {


