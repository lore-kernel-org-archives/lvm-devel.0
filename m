From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 15 Oct 2020 09:17:19 +0000 (GMT)
Subject: master - make: generate
Message-ID: <20201015091719.782F5385780B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b50134dc14296bf9bee96f3b4021ba5b123d54c9
Commit:        b50134dc14296bf9bee96f3b4021ba5b123d54c9
Parent:        616e5b854c23a781372b2d05564959b4ba593069
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 15 11:16:54 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 15 11:16:54 2020 +0200

make: generate

---
 man/lvconvert.8_pregen | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index b3902a51c..9e22c85ff 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -929,6 +929,10 @@ Detach a cache from an LV.
 \fBlvconvert\fP \fB--splitcache\fP \fILV\fP\fI_thinpool_cache_cachepool_vdopool_writecache\fP
 .br
 .RS 4
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -2004,6 +2008,10 @@ Detach and delete a cache from an LV.
 \fBlvconvert\fP \fB--uncache\fP \fILV\fP\fI_thinpool_cache_vdopool_writecache\fP
 .br
 .RS 4
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br


