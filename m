From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:37 -0400
Subject: master - locking: introduce prioritized_section
Message-ID: <201803151004.w2FA4bZ3023641@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6365f011b00357e7f67fbe3aca0ca00ccf17ba66
Commit:        6365f011b00357e7f67fbe3aca0ca00ccf17ba66
Parent:        043f58452a0a2c136dd6a90f1d60b063ae17a866
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 15 09:07:24 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 10:59:42 2018 +0100

locking: introduce prioritized_section

Introduce prioritized_section() as a closer match to previous logic
of critical_section() that has been held over longer sequence of
ioctl commands - essentially it's matching operation on a single
cookie.

While 'critical_section()' now corresponds to locked memory - we hold
this memory only between suspend/resume thus notion of 'cookie' was
lost.

This patch restores some logic unintentionaly lost with dropping
memory locking for just activation/deactivation calls.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |    5 +++++
 lib/mm/memlock.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a545a5d..da5f5f4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add prioritized_section() to restore cookie boundaries (2.02.177).
   Enhance error messages when read error happens.
   Enhance mirror log initialization for old mirror target.
   Skip private crypto and stratis devices.
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 897bf10..b55cc97 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -634,6 +634,11 @@ int critical_section(void)
 	return _critical_section;
 }
 
+int prioritized_section(void)
+{
+	return _priority_raised;
+}
+
 /*
  * The memlock_*_daemon functions will force the mlockall() call that we need
  * to stay in memory, but they will have no effect on device scans (unlike
diff --git a/lib/mm/memlock.h b/lib/mm/memlock.h
index ef2ebcb..d0807d5 100644
--- a/lib/mm/memlock.h
+++ b/lib/mm/memlock.h
@@ -34,6 +34,7 @@ struct cmd_context;
 void critical_section_inc(struct cmd_context *cmd, const char *reason);
 void critical_section_dec(struct cmd_context *cmd, const char *reason);
 int critical_section(void);
+int prioritized_section(void);
 void memlock_inc_daemon(struct cmd_context *cmd);
 void memlock_dec_daemon(struct cmd_context *cmd);
 int memlock_count_daemon(void);


