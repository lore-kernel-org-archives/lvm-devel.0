From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 15:07:21 +0000 (UTC)
Subject: master - lvmetad: fix compile without lvmetad
Message-ID: <20160421150721.19CA360FA5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e6f8025ff6ad8b3909a4631f71f310821ea7d4b
Commit:        6e6f8025ff6ad8b3909a4631f71f310821ea7d4b
Parent:        e44c4806db2424c6e375ac06391f0bcd475e6ce7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 10:06:47 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 10:06:47 2016 -0500

lvmetad: fix compile without lvmetad

Last commit was missing stub function.
---
 lib/cache/lvmetad.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 240610b..0985a54 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -165,6 +165,7 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #    define lvmetad_used()		(0)
 #    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_socket_present()	(0)
+#    define lvmetad_pidfile_present()   (0)
 #    define lvmetad_set_token(a)	do { } while (0)
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)


