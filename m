From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Sep 2016 20:51:24 +0000 (UTC)
Subject: master - tests: correcting kernel version test
Message-ID: <20160920205124.E155160A2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78e0fdb6182e8cae26998510760caf7afe237c39
Commit:        78e0fdb6182e8cae26998510760caf7afe237c39
Parent:        9f6b0062727e9ef33610880444eaee857de1ab92
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 20 22:50:43 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 20 22:50:43 2016 +0200

tests: correcting  kernel version test

Debug force leaked in.
---
 test/lib/brick-shelltest.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 1c9a1f3..7c5b601 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -571,7 +571,7 @@ struct KMsg : Source {
         // Can't use kmsg on kernels pre 3.5, read /var/log/messages
         if ( ( ::uname(&uts) == 0 ) &&
             ( ::sscanf( uts.release, "%u.%u.%u", &kmaj, &kmin, &krel ) == 3 ) &&
-            ( ( kmaj < 5 ) || ( ( kmaj == 3 ) && ( kmin < 5 ) ) ) )
+            ( ( kmaj < 3 ) || ( ( kmaj == 3 ) && ( kmin < 5 ) ) ) )
             can_clear = false, read_msg = "/var/log/messages";
 
         if ( ( fd = open(read_msg, O_RDONLY | O_NONBLOCK)) < 0 ) {


