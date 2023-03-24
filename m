From: Simon Rowe <simon.rowe@nutanix.com>
Date: Fri, 24 Mar 2023 09:32:28 +0000
Subject: [PATCH 1/2] cmdline: use freopen() to reopen standard streams
Message-ID: <20230324093229.23480-1-simon.rowe@nutanix.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In glibc stdin, stdout & stderr are variables that can be assigned to
(https://www.gnu.org/software/libc/manual/html_node/Standard-Streams.html)
however this not necessarily true of other C libraries.

The gentoo musl porting notes
(https://wiki.gentoo.org/wiki/Musl_porting_notes)
recommend the substitution of

    stdX = fopen(...)

with

    freopen(..., stdX)

Signed-off-by: Simon Rowe <simon.rowe@nutanix.com>
---
 tools/lvmcmdline.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a5bb6a5c5..dafff5ba4 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3422,7 +3422,11 @@ static int _check_standard_fds(void)
 	int err = is_valid_fd(STDERR_FILENO);
 
 	if (!is_valid_fd(STDIN_FILENO) &&
+#ifdef __GLIBC__
 	    !(stdin = fopen(_PATH_DEVNULL, "r"))) {
+#else
+	    !freopen(_PATH_DEVNULL, "r", stdin)) {
+#endif
 		if (err)
 			perror("stdin stream open");
 		else
@@ -3432,7 +3436,11 @@ static int _check_standard_fds(void)
 	}
 
 	if (!is_valid_fd(STDOUT_FILENO) &&
+#ifdef __GLIBC__
 	    !(stdout = fopen(_PATH_DEVNULL, "w"))) {
+#else
+	    !freopen(_PATH_DEVNULL, "w", stdout)) {
+#endif
 		if (err)
 			perror("stdout stream open");
 		/* else no stdout */
@@ -3440,7 +3448,11 @@ static int _check_standard_fds(void)
 	}
 
 	if (!is_valid_fd(STDERR_FILENO) &&
+#ifdef __GLIBC__
 	    !(stderr = fopen(_PATH_DEVNULL, "w"))) {
+#else
+	    !freopen(_PATH_DEVNULL, "w", stderr)) {
+#endif
 		printf("stderr stream open: %s\n",
 		       strerror(errno));
 		return 0;
-- 
2.22.3

