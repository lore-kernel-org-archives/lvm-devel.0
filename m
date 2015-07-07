From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  7 Jul 2015 12:27:05 +0000 (UTC)
Subject: master - conf: regenerate
Message-ID: <20150707122705.6FDEC60D34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a405b89555c8a525900d9d81a413cc240ff6c840
Commit:        a405b89555c8a525900d9d81a413cc240ff6c840
Parent:        88760141da6593373f64a0791edd4bbea29680cc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 7 14:27:00 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 7 14:27:00 2015 +0200

conf: regenerate

---
 conf/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 4d73c5c..3207955 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -920,7 +920,7 @@ global {
 
 	# Configuration option global/cache_check_options.
 	# List of options passed to the cache_check command.
-	# cache_check_options = [ "-q" ]
+	# cache_check_options = [ "-q", "--clear-needs-check-flag" ]
 
 	# Configuration option global/cache_repair_options.
 	# List of options passed to the cache_repair command.


