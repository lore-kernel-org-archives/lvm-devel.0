From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:10 -0400
Subject: master - devcache: correct logging severity for connection
Message-ID: <201707171140.v6HBeAlH022477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea96a9d68eadd3505330db73856418c253080dba
Commit:        ea96a9d68eadd3505330db73856418c253080dba
Parent:        919fa89482b85eb467ecd9561c89c1dfdaae7217
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 18:23:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:28:51 2017 +0200

devcache: correct logging severity for connection

Switch from warn to log_error since this generated
failing return code for command so printing log_error()
is mandatory.

Happens with i.e. pvscan --cache meets crashing lvmetad.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2fece12..818458c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Log error instad of warn when noticing connection problem with lvmetad.
   Fix memory leak in lvmetad when working with duplicates.
   Accept 'lvm -h' and 'lvm --help' as well as 'lvm help' for help.
   Suppress error message from accept() on clean lvmetad shutdown.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 531e01c..5490675 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -662,7 +662,7 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	}
 
 	if (reply.error) {
-		log_warn("WARNING: lvmetad cannot be used due to error: %s", strerror(reply.error));
+		log_error("lvmetad cannot be used due to error: %s", strerror(reply.error));
 		goto fail;
 	}
 


