From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:07 -0400
Subject: master - coverity: use better function
Message-ID: <201706271020.v5RAK7TY003883@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e907535ab977ea29319aeb015cec6c06729f7ce4
Commit:        e907535ab977ea29319aeb015cec6c06729f7ce4
Parent:        e9c60f874ef02c8c5539310223e61e73a8103681
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 10:17:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:15:42 2017 +0200

coverity: use better function

---
 lib/log/log.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index f9d5649..8f52623 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -375,8 +375,8 @@ void fin_syslog(void)
 
 void init_msg_prefix(const char *prefix)
 {
-	strncpy(_msg_prefix, prefix, sizeof(_msg_prefix) - 1);
-	_msg_prefix[sizeof(_msg_prefix) - 1] = '\0';
+	if (prefix)
+		dm_strncpy(_msg_prefix, prefix, sizeof(_msg_prefix) - 1);
 }
 
 void init_indent(int indent)


