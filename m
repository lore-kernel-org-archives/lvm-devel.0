From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 14:03:05 +0000 (GMT)
Subject: main - tests: a bit more fancy way to initialized struct
Message-ID: <20210920140305.1168A3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a8a33ae9b39567e2a2cc399f13cebecb5fa2dea
Commit:        1a8a33ae9b39567e2a2cc399f13cebecb5fa2dea
Parent:        4c0354fe0fc2f42ec35c57cc69444a825e5c5386
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 16:01:22 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 16:01:22 2021 +0200

tests: a bit more fancy way to initialized struct

Older g++ is not smart enough to figure this out, so add a bit more push.
---
 test/lib/brick-shelltest.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index b3b62a308..af2810521 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -988,7 +988,7 @@ struct TestCase {
 
     TestCase( Journal &j, Options opt, std::string path, std::string _name, std::string _flavour )
         : child( path ), name( _name ), flavour( _flavour ),
-          iobuf( NULL ), usage( { 0 } ), status( 0 ), timeout( false ),
+          iobuf( NULL ), usage( (struct rusage) { { 0 } } ), status( 0 ), timeout( false ),
           pid( 0 ), start( 0 ), end( 0 ), silent_start( 0 ),
           last_update( 0 ), last_heartbeat( 0 ), options( opt ), journal( &j )
     {


