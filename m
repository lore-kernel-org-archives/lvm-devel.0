From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:15 +0200
Subject: [PATCH 4/6] Add attribute printf
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <426483269958ba2f0ef7b962dcd8bd7164f8fdac.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

gcc suggested to add these __atributes__ for instrumentation
of printf parametr - so making it a bit happier.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    1 +
 libdm/libdm-common.c        |    3 +++
 tools/dmsetup.c             |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index a64295f..fe5f019 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -567,6 +567,7 @@ static void _unregister_for_timeout(struct thread_status *thread)
 	pthread_mutex_unlock(&_timeout_mutex);
 }
 
+__attribute__((format(printf, 4, 5)))
 static void _no_intr_log(int level, const char *file, int line,
 			const char *f, ...)
 {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index c5780e7..7cce3a7 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -78,6 +78,7 @@ static int _udev_checking = 1;
  * function.
  */
 
+__attribute__((format(printf, 5, 0)))
 static void _default_log_line(int level,
 	    const char *file __attribute__((unused)),
 	    int line __attribute__((unused)), int dm_errno, 
@@ -101,6 +102,7 @@ static void _default_log_line(int level,
 		fprintf(use_stderr ? stderr : stdout, "\n");
 }
 
+__attribute__((format(printf, 5, 6)))
 static void _default_log_with_errno(int level,
 	    const char *file __attribute__((unused)),
 	    int line __attribute__((unused)), int dm_errno, 
@@ -113,6 +115,7 @@ static void _default_log_with_errno(int level,
 	va_end(ap);
 }
 
+__attribute__((format(printf, 4, 5)))
 static void _default_log(int level, const char *file,
 			 int line, const char *f, ...)
 {
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index fb71350..5455369 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1050,6 +1050,7 @@ static int _udevreleasecookie(CMD_ARGS)
 	return dm_udev_wait(_udev_cookie);
 }
 
+__attribute__((format(printf, 1, 2)))
 static char _yes_no_prompt(const char *prompt, ...)
 {
 	int c = 0, ret = 0;
-- 
1.7.4.1


