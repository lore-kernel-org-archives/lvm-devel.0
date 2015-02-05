From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:36 +0000 (UTC)
Subject: master - test: Add time/rusage formatting to the runner.
Message-ID: <20150205134136.02AFF60F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a665b9062395e69327aa3ecfb85a047f759e8db7
Commit:        a665b9062395e69327aa3ecfb85a047f759e8db7
Parent:        3fbea6029d77ce49434d0680b34d9dd367bce755
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 23:19:21 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Add time/rusage formatting to the runner.

---
 test/lib/runner.cpp |   46 +++++++++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index b617110..7fcf9e2 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -30,6 +30,8 @@
 #include "filesystem.h"
 
 #include <iostream>
+#include <iomanip>
+
 #include <vector>
 #include <deque>
 #include <map>
@@ -200,6 +202,31 @@ struct TestCase {
 		return true;
 	}
 
+	std::string timefmt( time_t t ) {
+		std::stringstream ss;
+		ss << t / 60 << ":" << std::setw( 2 ) << std::setfill( '0' ) << t % 60;
+		return ss.str();
+	}
+
+	std::string rusage()
+	{
+		std::stringstream ss;
+		time_t wall = end - start, user = usage.ru_utime.tv_sec,
+		     system = usage.ru_stime.tv_sec;
+		size_t rss = usage.ru_maxrss / 1024,
+		       inb = usage.ru_inblock / 100,
+		      outb = usage.ru_oublock / 100;
+
+		size_t inb_10 = inb % 10, outb_10 = outb % 10;
+		inb /= 10; outb /= 10;
+
+		ss << timefmt( wall ) << " wall " << timefmt( user ) << " user "
+		   << timefmt( system ) << " sys   " << std::setw( 3 ) << rss << "M RSS | "
+		   << "IOPS: " << std::setw( 5 ) << inb << "." << inb_10 << "K in "
+		               << std::setw( 5 ) << outb << "." << outb_10 << "K out";
+		return ss.str();
+	}
+
 	std::string tag( std::string n ) {
 		int pad = (12 - n.length());
 		return "### " + std::string( pad, ' ' ) + n + ": ";
@@ -401,25 +428,6 @@ static int64_t get_time_us(void)
 }
 
 
-static const char *duration(time_t start, const struct rusage *usage)
-{
-	static char buf[100];
-	int t = (int)(time(NULL) - start);
-
-	int p = sprintf(buf, "%2d:%02d walltime", t / 60, t % 60);
-
-	if (usage)
-		sprintf(buf + p, "   %2ld:%02ld.%03ld u, %ld:%02ld.%03ld s, %5ldk rss, %8ld/%ld IO",
-			usage->ru_utime.tv_sec / 60, usage->ru_utime.tv_sec % 60,
-			usage->ru_utime.tv_usec / 1000,
-			usage->ru_stime.tv_sec / 60, usage->ru_stime.tv_sec % 60,
-			usage->ru_stime.tv_usec / 1000,
-			usage->ru_maxrss / 1024,
-			usage->ru_inblock, usage->ru_oublock);
-
-	return buf;
-}
-
 struct Args {
 	typedef std::vector< std::string > V;
 	V args;


