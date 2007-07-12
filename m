From: Jim Meyering <meyering@redhat.com>
Date: Thu, 12 Jul 2007 09:02:25 +0200
Subject: small improvements
In-Reply-To: <20070708225122.22491.qmail@sourceware.org> (agk@sourceware.org's
	message of "8 Jul 2007 22\:51\:22 -0000")
References: <20070708225122.22491.qmail@sourceware.org>
Message-ID: <878x9mm7em.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I was reading recent patches and saw a couple ways to
make small improvements.

I hope you don't mind...


Subject: [PATCH] (_line_append): Add __attribute__ ((format(printf...

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 lib/config/config.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index b5f0038..f8ed9ee 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -361,6 +361,8 @@ static int _line_start(struct output_line *outline)
 }
 
 static int _line_append(struct output_line *outline, const char *fmt, ...)
+  __attribute__ ((format(printf, 2, 3)));
+static int _line_append(struct output_line *outline, const char *fmt, ...)
 {
 	char buf[4096];
 	va_list ap;



Subject: [PATCH] Don't hard-code 4095.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 lib/config/config.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index f8ed9ee..d3d7e4d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -367,10 +367,11 @@ static int _line_append(struct output_line *outline, const char *fmt, ...)
 	char buf[4096];
 	va_list ap;
 	int n;
+	size_t lim = sizeof buf - 1;
 
 	va_start(ap, fmt);
-	n = vsnprintf(&buf[0], 4095, fmt, ap);
-	if (n < 0 || n > 4095) {
+	n = vsnprintf(buf, lim, fmt, ap);
+	if (n < 0 || n > lim) {
 		log_error("vsnprintf failed for config line");
 		return 0;
 	}


