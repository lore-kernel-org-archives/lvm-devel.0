From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 Oct 2015 08:01:28 +0000 (UTC)
Subject: master - conf: regenerate
Message-ID: <20151019080128.8757260042@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ea7e2634d67a7628508a677668a00f748aee0b0
Commit:        1ea7e2634d67a7628508a677668a00f748aee0b0
Parent:        23d9b17a7b06d8e6f89b2c3e9ef9f59462436458
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 19 10:01:14 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 19 10:01:14 2015 +0200

conf: regenerate

---
 conf/example.conf.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index dddede0..e96f03f 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -389,8 +389,8 @@ allocation {
 	# This configuration option does not have a default value defined.
 
 	# Configuration section allocation/cache_settings.
-	# Individual settings for policies.
-	# See the help for individual policies for more info.
+	# Settings for the cache policy.
+	# See documentation for individual cache policies for more info.
 	# This configuration section has an automatic default value.
 	# cache_settings {
 	# }


