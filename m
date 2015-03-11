From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 10:01:53 +0000 (UTC)
Subject: master - tests: extend test timeout to 180sec
Message-ID: <20150311100153.DC1A060DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db5166fbfab2c7455fd97fd73afc6c1139b0ddc4
Commit:        db5166fbfab2c7455fd97fd73afc6c1139b0ddc4
Parent:        760cebf47dde020b42e44b35a0ad81204b6047e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 10:46:51 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 11:02:35 2015 +0100

tests: extend test timeout to 180sec

Some test could take more then minute (with slow udev and slow
emulation) - extend timeout to 180sec.
---
 test/lib/brick-shelltest.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index d67b164..4f0e1bf 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -650,7 +650,7 @@ struct Options {
     int timeout;
     Options() : verbose( false ), batch( false ), interactive( false ),
                 cont( false ), fatal_timeouts( false ), kmsg( false ),
-                timeout( 60 ) {}
+                timeout( 180 ) {}
 };
 
 struct TestProcess


