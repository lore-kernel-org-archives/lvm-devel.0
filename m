From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:13 +0000 (UTC)
Subject: master - lvmetad: fix leak of append on error path
Message-ID: <20121014212113.C9DC722FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=920352da70245f9b385aa0465f9ee88091676371
Commit:        920352da70245f9b385aa0465f9ee88091676371
Parent:        6595cae6e9b65658430714b9731b604c036d0816
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 21:04:01 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:14:48 2012 +0200

lvmetad: fix leak of append on error path

---
 libdaemon/client/config-util.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 1f4b55b..1c83134 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -55,7 +55,7 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 
 		if (!append ||
 		    !buffer_append(buf, append))
-			return 0;
+			goto fail;
 
 		dm_free(append);
 	}


