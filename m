From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:45 -0500
Subject: master - cleanup: explicitely ignore result code
Message-ID: <201802282022.w1SKMjkC009870@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e643de6e61e9329c84286941511242f0f0d2e71b
Commit:        e643de6e61e9329c84286941511242f0f0d2e71b
Parent:        805bf6ec740845de0de55d3706220d84f3ad6edb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 25 16:18:31 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

cleanup: explicitely ignore result code

ATM too long prefix is silently ignored.
---
 lib/log/log.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 808090f..79fbd7a 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -376,7 +376,8 @@ void fin_syslog(void)
 void init_msg_prefix(const char *prefix)
 {
 	if (prefix)
-		dm_strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
+		/* Cut away too long prefix */
+		(void) dm_strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
 }
 
 void init_indent(int indent)


