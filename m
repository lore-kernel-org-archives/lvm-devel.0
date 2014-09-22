From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:38:39 +0000 (UTC)
Subject: dev-dct-process-latest - va_list: properly pass va_list through functions
Message-ID: <20140922153839.7780D60EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ce21c19d5894b889a6d8da67c8a159709c3dda9
Commit:        1ce21c19d5894b889a6d8da67c8a159709c3dda9
Parent:        b9c16b750694c4ec03d05bc9e4a12cecc4d9450f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 15 15:33:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 16 11:42:40 2014 +0200

va_list: properly pass va_list through functions

Code should not just pass va_list arg through the function
as args could be passed in many strange ways.
Use va_copy().

For details look in i.e.:

http://julipedia.meroh.net/2011/09/using-vacopy-to-safely-pass-ap.html
---
 WHATS_NEW                        |    1 +
 lib/format_text/export.c         |    5 ++++-
 libdaemon/client/daemon-client.c |   16 ++++++++++++----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5b8a32f..d3f926d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Use va_copy to properly pass va_list through functions.
   Add function to detect rotational devices.
   Review internal checks for mirror/raid/pvmove volumes.
   Track mirror segment type with separate MIRROR flag.
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 7ffb4e3..c2453f2 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -190,9 +190,12 @@ static int _out_with_comment_raw(struct formatter *f,
 				 const char *fmt, va_list ap)
 {
 	int n;
+	va_list apc;
 
+	va_copy(apc, ap);
 	n = vsnprintf(f->data.buf.start + f->data.buf.used,
-		      f->data.buf.size - f->data.buf.used, fmt, ap);
+		      f->data.buf.size - f->data.buf.used, fmt, apc);
+	va_end(apc);
 
 	/* If metadata doesn't fit, extend buffer */
 	if (n < 0 || (n + f->data.buf.used + 2 > f->data.buf.size)) {
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index a11b604..d0b8951 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -129,12 +129,16 @@ daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 	static const daemon_reply err = { .error = ENOMEM };
 	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
+	va_list apc;
 
+	va_copy(apc, ap);
 	if (!buffer_append_f(&rq.buffer, "request = %s", id, NULL) ||
-	    !buffer_append_vf(&rq.buffer, ap)) {
+	    !buffer_append_vf(&rq.buffer, apc)) {
+		va_end(apc);
 		buffer_destroy(&rq.buffer);
 		return err;
 	}
+	va_end(apc);
 
 	repl = daemon_send(h, rq);
 	buffer_destroy(&rq.buffer);
@@ -181,13 +185,17 @@ bad:
 
 int daemon_request_extend_v(daemon_request r, va_list ap)
 {
+	int res;
+	va_list apc;
+
 	if (!r.cft)
 		return 0;
 
-	if (!config_make_nodes_v(r.cft, NULL, r.cft->root, ap))
-		return 0;
+	va_copy(apc, ap);
+	res = config_make_nodes_v(r.cft, NULL, r.cft->root, apc) ? 1 : 0;
+	va_end(apc);
 
-	return 1;
+	return res;
 }
 
 int daemon_request_extend(daemon_request r, ...)


