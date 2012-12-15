From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:23 +0000 (UTC)
Subject: master - format-text: check for _text_create_text_instance
Message-ID: <20121215162523.CB9C8AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff5612c0c3208276763348e9f9afa9a09096fbe1
Commit:        ff5612c0c3208276763348e9f9afa9a09096fbe1
Parent:        740ab81d03b1286096d9f8b35be15d54493db52f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:34:28 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:23 2012 +0100

format-text: check for _text_create_text_instance

Test if 'fid' creation failed and report stack trace,
break the loop and do not pass NULL fid further.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 249db0b..fcb8897 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add check for created fid in _scan_file.
   Log output also to syslog when abort_on_internal_error is set.
   Add LV snapshot support to liblvm and python-lvm.
   Avoid a global lock in pvs when lvmetad is in use.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 476d5d9..227289f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1089,7 +1089,10 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 				/* FIXME: Check this fid is OK! */
 				fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 				fic.context.private = NULL;
-				fid = _text_create_text_instance(fmt, &fic);
+				if (!(fid = _text_create_text_instance(fmt, &fic))) {
+					stack;
+					break;
+				}
 				if ((vg = _vg_read_file_name(fid, scanned_vgname,
 							     path))) {
 					/* FIXME Store creation host in vg */


