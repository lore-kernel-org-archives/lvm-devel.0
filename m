From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Feb 2015 12:23:34 +0000 (UTC)
Subject: master - conf: update profile templates for recent changes
Message-ID: <20150211122334.3684660552@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b88b75f55f54bf07780d389a750bc899f7bed8a9
Commit:        b88b75f55f54bf07780d389a750bc899f7bed8a9
Parent:        437b17964cfe8fc73fe224589c62c47f2b2665dc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 11 13:22:31 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 11 13:22:31 2015 +0100

conf: update profile templates for recent changes

---
 conf/command_profile_template.profile.in  |    1 +
 conf/metadata_profile_template.profile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 0c1e6f0..402e30c 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -18,6 +18,7 @@ global {
 	lvdisplay_shows_full_device_path=0
 }
 report {
+	compact_output=0
 	aligned=1
 	buffered=1
 	headings=1
diff --git a/conf/metadata_profile_template.profile.in b/conf/metadata_profile_template.profile.in
index 81633b2..b08d32c 100644
--- a/conf/metadata_profile_template.profile.in
+++ b/conf/metadata_profile_template.profile.in
@@ -16,7 +16,7 @@ allocation {
 	thin_pool_zero=1
 	thin_pool_discards="passdown"
 	thin_pool_chunk_size_policy="generic"
-#	thin_pool_chunk_size=64
+#	thin_pool_chunk_size=128
 }
 activation {
 	thin_pool_autoextend_threshold=100


