From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:05 +0000 (UTC)
Subject: master - lvmetad: fix compare function
Message-ID: <20130618201405.8204B60ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=155841c349c58e2332802d85f3c39b8933cdd761
Commit:        155841c349c58e2332802d85f3c39b8933cdd761
Parent:        e3d39217794731402cedddb9cbaebf75c08c97ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 18 21:58:13 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:12:51 2013 +0200

lvmetad: fix compare function

Check for enough space in preallocated buffer.
Fixes problem, when lvm code started to suddenly allocate
too big memory chunks.

TODO: lvmetad protocol should announce needed size ahead,
so if metadata have 1MB we are not reallocating memory...
---
 WHATS_NEW                    |    1 +
 libdaemon/client/daemon-io.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1eb440f..19bcf82 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix use of too big chunks of memory when communication with lvmetad.
   Fix vgcfgrestore crash when specified incorrect vg name.
   Refine lvm.conf and man page documentation for autoactivation feature.
   Add support for thin volumes in vgsplit.
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 37f2744..6ede8a8 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -41,7 +41,7 @@ int buffer_read(int fd, struct buffer *buffer) {
 				buffer->used -= 4;
 				break; /* success, we have the full message now */
 			}
-			if (buffer->used - buffer->allocated < 32)
+			if (buffer->allocated - buffer->used < 32)
 				if (!buffer_realloc(buffer, 1024))
 					goto fail;
 			continue;


