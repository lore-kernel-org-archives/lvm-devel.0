From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Jul 2012 08:44:52 +0000 (UTC)
Subject: master - conf: add a comment about obsolete .cache file
Message-ID: <20120716084452.BBE9C14E8@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35ebc5d343e2e01b719ce15c801d522a36e54ac4
Commit:        35ebc5d343e2e01b719ce15c801d522a36e54ac4
Parent:        07e4ac7b00f680ad88aa0ff4c835ea2b27eab44b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 16 10:43:04 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 16 10:43:04 2012 +0200

conf: add a comment about obsolete .cache file

---
 doc/example.conf.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index fbb9271..a085014 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -86,6 +86,9 @@ devices {
     # It is safe to delete the contents: the tools regenerate it.
     # (The old setting 'cache' is still respected if neither of
     # these new ones is present.)
+    # N.B. This type of caching is obsolete and existing .cache
+    # file is removed if the list of devices is obtained from
+    # udev by setting the obtain_device_list_from_udev to 1.
     cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
     cache_file_prefix = ""
 


