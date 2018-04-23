From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:48:46 -0400
Subject: master - independent metadata areas: fix bogus code
Message-ID: <201804231348.w3NDmks7031505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=098c843c50cdcc2e4f4162037e1ff5975624f3e2
Commit:        098c843c50cdcc2e4f4162037e1ff5975624f3e2
Parent:        d9ef9eb330bdc66dd6d9b45713d5c0b25d645ac0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 25 13:55:22 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:21:41 2018 -0500

independent metadata areas: fix bogus code

Fix mixing bitwise & and logical && which was
always 1 in any case.
---
 lib/format_text/format-text.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 8c12c82..9538080 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1362,7 +1362,9 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 
 static int _text_scan(const struct format_type *fmt, const char *vgname)
 {
-	return (_scan_file(fmt, vgname) & _scan_raw(fmt, vgname));
+	_scan_file(fmt, vgname);
+	_scan_raw(fmt, vgname);
+	return 1;
 }
 
 struct _write_single_mda_baton {


