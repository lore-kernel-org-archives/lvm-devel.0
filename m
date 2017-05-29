From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:25 -0400
Subject: master - cleanup: bad flag is internal error here
Message-ID: <201705291255.v4TCtPpO002334@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e0bc73eba4db74cb92fe884687f1cbfd4b20930
Commit:        8e0bc73eba4db74cb92fe884687f1cbfd4b20930
Parent:        597b3576c7399d76ab4da5dccf505f2f2cc4fce2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 26 15:45:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:47:16 2017 +0200

cleanup: bad flag is internal error here

Convert to internal error.
---
 lib/format_text/flags.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a9f81f5..41f3608 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -114,7 +114,7 @@ static const struct flag *_get_flags(int type)
 		return _lv_flags;
 	}
 
-	log_error("Unknown flag set requested.");
+	log_error(INTERNAL_ERROR "Unknown flag set requested.");
 	return NULL;
 }
 


