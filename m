From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:18 +0000 (UTC)
Subject: master - memlock: report memlock daemon counter
Message-ID: <20151022213318.45CAE60DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b78d496bf4e80dab82824a70b1d1d852e7cc1fb
Commit:        7b78d496bf4e80dab82824a70b1d1d852e7cc1fb
Parent:        19e272ba53a51a0f3103e1d5e04d06b6207f0acc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:43:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:26:27 2015 +0200

memlock: report memlock daemon counter

Add internal memlock_count_daemon().

Function can be used to recognize it's being executed
from daemon restricted execution inside /lib code.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |    5 +++++
 lib/mm/memlock.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ece92e0..8ffbeca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Support checking of memlock daemon counter.
   Allow all log levels to be used with the lvmetad -l option.
   Add optional shutdown when idle support for lvmetad.
   Fix missing in-sync progress info while lvconvert used with lvmpolld.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 60686ea..34a6eff 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -638,3 +638,8 @@ void memlock_unlock(struct cmd_context *cmd)
 }
 
 #endif
+
+int memlock_count_daemon()
+{
+	return _memlock_count_daemon;
+}
diff --git a/lib/mm/memlock.h b/lib/mm/memlock.h
index aab9c85..3ec5ed8 100644
--- a/lib/mm/memlock.h
+++ b/lib/mm/memlock.h
@@ -36,6 +36,7 @@ void critical_section_dec(struct cmd_context *cmd, const char *reason);
 int critical_section(void);
 void memlock_inc_daemon(struct cmd_context *cmd);
 void memlock_dec_daemon(struct cmd_context *cmd);
+int memlock_count_daemon(void);
 void memlock_init(struct cmd_context *cmd);
 void memlock_reset(void);
 void memlock_unlock(struct cmd_context *cmd);


