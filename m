From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:45 +0000 (GMT)
Subject: master - tests: check for writecache being compiled in
Message-ID: <20200908220345.07C0F386F038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=676ce4775464dbc2efbcfe09951c55991dc5be3d
Commit:        676ce4775464dbc2efbcfe09951c55991dc5be3d
Parent:        8dea63d30fd336051ec549d96c70abef6a9bfdec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 21:08:32 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

tests: check for writecache being compiled in

---
 test/shell/cache-single-usage.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
index 8936aa3f1..9bc9b67c5 100644
--- a/test/shell/cache-single-usage.sh
+++ b/test/shell/cache-single-usage.sh
@@ -16,6 +16,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+lvm segtypes 2>/dev/null | grep writecache$ >/dev/null || {
+	skip 'Writecache is not built-in.'
+}
 aux have_cache 1 10 0 || skip
 which mkfs.xfs || skip
 


