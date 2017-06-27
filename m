From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 27 Jun 2017 07:46:50 -0400
Subject: master - log: fix message prefix truncation
Message-ID: <201706271146.v5RBkoGS015233@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f1ec681d65001ed3c74a7c7239efa98a8507d88
Commit:        7f1ec681d65001ed3c74a7c7239efa98a8507d88
Parent:        3fe67217d46d2bb496b5c09b0314c7260ed6c24f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 27 12:41:59 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 27 12:41:59 2017 +0100

log: fix message prefix truncation

Restore the 29-character prefix limit that commit
e907535ab977ea29319aeb015cec6c06729f7ce4 ("coverity: use better
function") accidentally reduced to 28 characters.
---
 lib/log/log.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 8f52623..8ca60e4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -376,7 +376,7 @@ void fin_syslog(void)
 void init_msg_prefix(const char *prefix)
 {
 	if (prefix)
-		dm_strncpy(_msg_prefix, prefix, sizeof(_msg_prefix) - 1);
+		dm_strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
 }
 
 void init_indent(int indent)


