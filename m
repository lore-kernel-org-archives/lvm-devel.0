From: saulery@free.fr <saulery@free.fr>
Date: Wed, 12 Nov 2014 13:39:37 +0100
Subject: lvmcache.7.in: fix syntax error (line continuation \\)
In-Reply-To: <1415795977-4518-1-git-send-email-saulery@free.fr>
References: <1415795977-4518-1-git-send-email-saulery@free.fr>
Message-ID: <1415795977-4518-3-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/lvmcache.7.in | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 79ceb64..75e2d54 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -88,11 +88,7 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
-.br
-.RS
-.B VG/CacheDataLV
-.RE
+.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV VG/CacheDataLV
 
 .I Example
 .br
-- 
2.1.1


