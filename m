From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:25 -0500
Subject: master - activation: split priority from memory locking
Message-ID: <201712011120.vB1BKPge029435@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c086dfadc389551b9a2d7b4c26931e5e74ada8d6
Commit:        c086dfadc389551b9a2d7b4c26931e5e74ada8d6
Parent:        c489dd2e1764216de07be80d36b1025fb4f6fc85
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 1 11:50:14 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

activation: split priority from memory locking

When entering any critical section, lvm2 used to lock process memory
and raised task priority to avoid problem with page swapping and minimize
time of having non-resumed devices in table.

With this patch, memory locking which which is expensive is only used when
entering  'suspending' section as only in this section there is risk
lvm could be suspending a device which later can be needed for paging.

Raised priority is still kept for all section entrances as this is
low-cost operation and may accelerate table resumes - although the real
impact can be still considered later.
---
 WHATS_NEW        |    1 +
 lib/mm/memlock.c |   99 ++++++++++++++++++++++++++++++++++++------------------
 2 files changed, 67 insertions(+), 33 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 093fc95..8bbe4ee 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Command will lock memory only when suspending volumes.
   Merge segments when pvmove is finished.
   Remove label_verify that has never been used.
   Ensure very large numbers used as arguments are not casted to lower values. 
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 389e213..7edd9de 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -85,6 +85,7 @@ static size_t _size_malloc = 2000000;
 
 static void *_malloc_mem = NULL;
 static int _mem_locked = 0;
+static int _priority_raised = 0;
 static int _critical_section = 0;
 static int _memlock_count_daemon = 0;
 static int _priority;
@@ -465,6 +466,38 @@ static int _restore_mmap(void)
 #endif /* ARCH_X86 */
 	return 1;
 }
+static void _raise_priority(struct cmd_context *cmd)
+{
+	if (_priority_raised)
+		return;
+
+	_priority_raised = 1;
+	errno = 0;
+	if (((_priority = getpriority(PRIO_PROCESS, 0)) == -1) && errno)
+		log_sys_debug("getpriority", "");
+	else if (_default_priority < _priority) {
+		if (setpriority(PRIO_PROCESS, 0, _default_priority) == 0)
+			log_debug_activation("Raised task priority %d -> %d.",
+					     _priority, _default_priority);
+		else
+			log_warn("WARNING: setpriority %d failed: %s.",
+				 _default_priority, strerror(errno));
+	}
+}
+
+static void _restore_priority_if_possible(struct cmd_context *cmd)
+{
+	if (!_priority_raised || _critical_section || _memlock_count_daemon)
+		return;
+
+	if (setpriority(PRIO_PROCESS, 0, _priority) == 0)
+		log_debug_activation("Restoring original task priority %d.", _priority);
+	else
+		log_warn("WARNING: setpriority %u failed: %s.",
+			 _priority, strerror(errno));
+
+	_priority_raised = 0;
+}
 
 /* Stop memory getting swapped out */
 static void _lock_mem(struct cmd_context *cmd)
@@ -502,14 +535,6 @@ static void _lock_mem(struct cmd_context *cmd)
 
 	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
 		stack;
-
-	errno = 0;
-	if (((_priority = getpriority(PRIO_PROCESS, 0)) == -1) && errno)
-		log_sys_error("getpriority", "");
-	else
-		if (setpriority(PRIO_PROCESS, 0, _default_priority))
-			log_error("setpriority %d failed: %s",
-				  _default_priority, strerror(errno));
 }
 
 static void _unlock_mem(struct cmd_context *cmd)
@@ -539,16 +564,15 @@ static void _unlock_mem(struct cmd_context *cmd)
 		}
 	}
 
-	if (setpriority(PRIO_PROCESS, 0, _priority))
-		log_error("setpriority %u failed: %s", _priority,
-			  strerror(errno));
+	_restore_priority_if_possible(cmd);
+
 	_release_memory();
 }
 
 static void _lock_mem_if_needed(struct cmd_context *cmd)
 {
-	log_debug_mem("Lock:   Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
-		      _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
+	log_debug_mem("Lock:   Memlock counters: prioritized:%d locked:%d critical:%d daemon:%d suspended:%d",
+		      _priority_raised, _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (!_mem_locked &&
 	    ((_critical_section + _memlock_count_daemon) == 1)) {
 		_mem_locked = 1;
@@ -558,8 +582,8 @@ static void _lock_mem_if_needed(struct cmd_context *cmd)
 
 static void _unlock_mem_if_possible(struct cmd_context *cmd)
 {
-	log_debug_mem("Unlock: Memlock counters: locked:%d critical:%d daemon:%d suspended:%d",
-		      _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
+	log_debug_mem("Unlock: Memlock counters: prioritized:%d locked:%d critical:%d daemon:%d suspended:%d",
+		      _priority_raised, _mem_locked, _critical_section, _memlock_count_daemon, dm_get_suspended_counter());
 	if (_mem_locked &&
 	    !_critical_section &&
 	    !_memlock_count_daemon) {
@@ -568,29 +592,41 @@ static void _unlock_mem_if_possible(struct cmd_context *cmd)
 	}
 }
 
+/*
+ * Critical section is only triggered with suspending reason.
+ * Other reasons only raise process priority so the table manipulation
+ * remains fast.
+ *
+ * Memory stays locked until 'memlock_unlock()' is called so when possible
+ * it may stay locked across multiple crictical section entrances.
+ */
 void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
-	/*
-	 * Profiles are loaded on-demand so make sure that before
-	 * entering the critical section all needed profiles are
-	 * loaded to avoid the disk access later.
-	 */
-	(void) load_pending_profiles(cmd);
-
-	if (!_critical_section) {
+	if (!_critical_section && (strcmp(reason, "suspending") == 0)) {
+		/*
+		 * Profiles are loaded on-demand so make sure that before
+		 * entering the critical section all needed profiles are
+		 * loaded to avoid the disk access later.
+		 */
+		(void) load_pending_profiles(cmd);
 		_critical_section = 1;
-		log_debug_mem("Entering critical section (%s).", reason);
-	}
+		log_debug_activation("Entering critical section (%s).", reason);
+		_lock_mem_if_needed(cmd);
+	} else
+		log_debug_activation("Entering prioritized section (%s).", reason);
 
-	_lock_mem_if_needed(cmd);
+	_raise_priority(cmd);
 }
 
 void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
 	if (_critical_section && !dm_get_suspended_counter()) {
 		_critical_section = 0;
-		log_debug_mem("Leaving critical section (%s).", reason);
-	}
+		log_debug_activation("Leaving critical section (%s).", reason);
+	} else
+		log_debug_activation("Leaving section (%s).", reason);
+
+	_restore_priority_if_possible(cmd);
 }
 
 int critical_section(void)
@@ -612,6 +648,7 @@ void memlock_inc_daemon(struct cmd_context *cmd)
 		log_error(INTERNAL_ERROR "_memlock_inc_daemon used in critical section.");
 	log_debug_mem("memlock_count_daemon inc to %d", _memlock_count_daemon);
 	_lock_mem_if_needed(cmd);
+	_raise_priority(cmd);
 }
 
 void memlock_dec_daemon(struct cmd_context *cmd)
@@ -620,11 +657,6 @@ void memlock_dec_daemon(struct cmd_context *cmd)
 		log_error(INTERNAL_ERROR "_memlock_count_daemon has dropped below 0.");
 	--_memlock_count_daemon;
 	log_debug_mem("memlock_count_daemon dec to %d", _memlock_count_daemon);
-	if (!_memlock_count_daemon && _critical_section && _mem_locked) {
-		log_error("Unlocking daemon memory in critical section.");
-		_unlock_mem(cmd);
-		_mem_locked = 0;
-	}
 	_unlock_mem_if_possible(cmd);
 }
 
@@ -641,6 +673,7 @@ void memlock_reset(void)
 {
 	log_debug_mem("memlock reset.");
 	_mem_locked = 0;
+	_priority_raised = 0;
 	_critical_section = 0;
 	_memlock_count_daemon = 0;
 }


