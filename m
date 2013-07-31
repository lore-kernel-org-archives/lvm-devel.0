From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:24 +0000 (UTC)
Subject: master - cleanup: use compile time strlen
Message-ID: <20130731133624.8612B60319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a722c5c8bcc902043ece29550a5d61ea7fdbef3
Commit:        4a722c5c8bcc902043ece29550a5d61ea7fdbef3
Parent:        ba1a8878d05e3753d9ae5a98e51afac71f078fc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 25 14:18:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:24:45 2013 +0200

cleanup: use compile time strlen

Use sizeof instead of strlen().
---
 lib/log/log.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index 06e053f..e0c1e73 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -196,8 +196,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
 	if (_abort_on_internal_errors &&
-	    !strncmp(format, INTERNAL_ERROR,
-		     strlen(INTERNAL_ERROR))) {
+	    !strncmp(format, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1)) {
 		fatal_internal_error = 1;
 		/* Internal errors triggering abort cannot be suppressed. */
 		_log_suppress = 0;


