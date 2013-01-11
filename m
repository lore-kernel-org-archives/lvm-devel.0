From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jan 2013 08:27:08 +0000 (UTC)
Subject: master - whatsnew
Message-ID: <20130111082708.64D2BA0C4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b760a7fa7de3b1e3d2db182e5c6fb472b4fe9a1
Commit:        2b760a7fa7de3b1e3d2db182e5c6fb472b4fe9a1
Parent:        9602e68577b43cf2090e680d7b4d2318c72009a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 11 09:26:51 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 11 09:26:51 2013 +0100

whatsnew

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d7e8c7d..c801f44 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -32,6 +32,7 @@ Version 2.02.99 -
   Do not verify udev operations if --noudevsync command option is used.
   Fix lvm2app and return lvseg discards property as string.
   Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
+  Recognise Storage Class Memory (IBM S/390) devices in filter.
   Recognise STEC skd devices in filter.
   Recognise Violin Memory vtms devices in filter.
   Add lvm.conf thin pool defs thin_pool_{chunk_size|discards|zero}.


