From: Simon Rowe <simon.rowe@nutanix.com>
Date: Fri, 24 Mar 2023 09:32:29 +0000
Subject: [PATCH 2/2] log: use freopen() to reopen standard streams
In-Reply-To: <20230324093229.23480-1-simon.rowe@nutanix.com>
References: <20230324093229.23480-1-simon.rowe@nutanix.com>
Message-ID: <20230324093229.23480-2-simon.rowe@nutanix.com>
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
 lib/log/log.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/lib/log/log.c b/lib/log/log.c
index 118a3ba42..a94016d81 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -208,7 +208,11 @@ int reopen_standard_stream(FILE **stream, const char *mode)
 
 	_check_and_replace_standard_log_streams(old_stream, new_stream);
 
+#ifdef __GLIBC__
 	*stream = new_stream;
+#else
+	freopen(NULL, mode, *stream);
+#endif
 	return 1;
 }
 
-- 
2.22.3

