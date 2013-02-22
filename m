From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Feb 2013 11:36:20 +0000 (UTC)
Subject: master - conf: add missing '=' for raid10_segtype_default
Message-ID: <20130222113621.0A08C16B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae6fae9b26b61bcd9cc031ec021224cb4ac28cba
Commit:        ae6fae9b26b61bcd9cc031ec021224cb4ac28cba
Parent:        bbc6378b73246d7ef00c16274fea38118531ae95
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 22 12:36:03 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 22 12:36:03 2013 +0100

conf: add missing '=' for raid10_segtype_default

---
 doc/example.conf.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index e6494e5..ab83c0c 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -513,7 +513,7 @@ global {
     #            this setting is not advised.
     # Specify the '--type <raid10|mirror>' option to override this default
     # setting.
-    raid10_segtype_default "mirror"
+    raid10_segtype_default = "mirror"
 
     # The default format for displaying LV names in lvdisplay was changed 
     # in version 2.02.89 to show the LV name and path separately.


