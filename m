From: David Teigland <teigland@sourceware.org>
Date: Mon, 3 Feb 2020 12:21:59 -0500
Subject: master - man: lvmcache writecache watermark percent
Message-ID: <45844.120020312215201309@us-mta-311.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64a82a1c79a4aaef5359150f960932aee4df1982
Commit:        64a82a1c79a4aaef5359150f960932aee4df1982
Parent:        bddbbcb98ca135b91aa688c04c1c8be7d76a2bd1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 3 11:21:24 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 3 11:21:24 2020 -0600

man: lvmcache writecache watermark percent

---
 man/lvmcache.7_main | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index fb91be8..d8e8dc7 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -221,14 +221,14 @@ $ lvconvert --type writecache --cachevol fast \\
 Tunable options are:
 
 .IP \[bu] 2
-high_watermark = <count>
+high_watermark = <percent>
 
-Start writeback when the number of used blocks reach this watermark
+Start writeback when the writecache usage reaches this percent (0-100).
 
 .IP \[bu] 2
-low_watermark = <count>
+low_watermark = <percent>
 
-Stop writeback when the number of used blocks drops below this watermark
+Stop writeback when the writecache usage reaches this percent (0-100).
 
 .IP \[bu] 2
 writeback_jobs = <count>



