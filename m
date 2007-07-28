From: Jim Meyering <jim@meyering.net>
Date: Sat, 28 Jul 2007 16:40:51 +0200
Subject: Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
Message-ID: <87vec4vbf0.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Looking at recent lvm-file.c changes, I stumbled upon a leak
that's surprisingly similar to the one fixed last week in
lib/locking/file_locking.c.  Here's the fix:

diff --git a/WHATS_NEW b/WHATS_NEW
index 44b1e98..243ca25 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
   Remove create_dir function; use now-equivalent dm_create_dir instead
   Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
   Fix clvmd if compiled with gulm support. (2.02.26)
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index caaebbe..7ce0a0b 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -245,6 +245,7 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)

 	if (fcntl(lockfd, F_SETLKW, &lock)) {
 		log_sys_error("fcntl", file);
+		close(lockfd);
 		return -1;
 	}

--
1.5.3.rc3.13.g7ab3


