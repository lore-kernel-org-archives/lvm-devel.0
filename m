From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:21 +0000 (UTC)
Subject: master - log: move abort past syslog
Message-ID: <20121215162521.66A8BAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=740ab81d03b1286096d9f8b35be15d54493db52f
Commit:        740ab81d03b1286096d9f8b35be15d54493db52f
Parent:        575c4ed96412edf513dbd0263983520a15b3b8bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:57:01 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:22:48 2012 +0100

log: move abort past syslog

When the abort_on_internal_errors is enabled, we aborted prior
the syslog logging output.

Since such fatal error gets level _LOG_FATAL it should
not be blocked by debug_level() check so lets move it further,
to get abort error logged also via syslog.
---
 WHATS_NEW     |    1 +
 lib/log/log.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 697e4d2..249db0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Log output also to syslog when abort_on_internal_error is set.
   Add LV snapshot support to liblvm and python-lvm.
   Avoid a global lock in pvs when lvmetad is in use.
   Fix crash in pvscan --cache -aay triggered by non-mda PV.
diff --git a/lib/log/log.c b/lib/log/log.c
index d50cb4a..3c357f1 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -344,9 +344,6 @@ void print_log(int level, const char *file, int line, int dm_errno,
 		va_end(ap);
 	}
 
-	if (fatal_internal_error)
-		abort();
-
 	if (level > debug_level())
 		return;
 
@@ -368,6 +365,9 @@ void print_log(int level, const char *file, int line, int dm_errno,
 		va_end(ap);
 	}
 
+	if (fatal_internal_error)
+		abort();
+
 	/* FIXME This code is unfinished - pre-extend & condense. */
 	if (!_already_logging && _log_direct && critical_section()) {
 		_already_logging = 1;


