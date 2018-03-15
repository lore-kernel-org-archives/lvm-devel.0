From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 07:35:05 -0400
Subject: master - activation: separate prioritized counter
Message-ID: <201803151135.w2FBZ5FE009329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9553dc77611e787999923a4cfeb223360ce00672
Commit:        9553dc77611e787999923a4cfeb223360ce00672
Parent:        f6f8f0c7fda823b1d7261472a6d724118ed19007
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 15 12:30:45 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 12:30:45 2018 +0100

activation: separate prioritized counter

While prioritized_section() based on raised priority works
nicely for standard lvm comman - separate counter is actually needed
when it's used in daemons like clvmd/dmeventd  where priority
stays raised all the time.
---
 lib/mm/memlock.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index b55cc97..b15058e 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -87,6 +87,7 @@ static void *_malloc_mem = NULL;
 static int _mem_locked = 0;
 static int _priority_raised = 0;
 static int _critical_section = 0;
+static int _prioritized_section = 0;
 static int _memlock_count_daemon = 0;
 static int _priority;
 static int _default_priority;
@@ -618,6 +619,7 @@ void critical_section_inc(struct cmd_context *cmd, const char *reason)
 		log_debug_activation("Entering prioritized section (%s).", reason);
 
 	_raise_priority(cmd);
+	_prioritized_section++;
 }
 
 void critical_section_dec(struct cmd_context *cmd, const char *reason)
@@ -627,6 +629,9 @@ void critical_section_dec(struct cmd_context *cmd, const char *reason)
 		log_debug_activation("Leaving critical section (%s).", reason);
 	} else
 		log_debug_activation("Leaving section (%s).", reason);
+
+	if (_prioritized_section > 0)
+		_prioritized_section--;
 }
 
 int critical_section(void)
@@ -636,7 +641,7 @@ int critical_section(void)
 
 int prioritized_section(void)
 {
-	return _priority_raised;
+	return _prioritized_section;
 }
 
 /*
@@ -680,6 +685,7 @@ void memlock_reset(void)
 	_mem_locked = 0;
 	_priority_raised = 0;
 	_critical_section = 0;
+	_prioritized_section = 0;
 	_memlock_count_daemon = 0;
 }
 


