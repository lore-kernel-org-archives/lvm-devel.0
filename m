From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 13 Nov 2014 17:05:26 +0000 (UTC)
Subject: master - lvmcache.7: remove unwanted line continuation syntax
Message-ID: <20141113170526.EF61760EA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=474c6a527139af59c46ca8ddf272ce5da4730954
Commit:        474c6a527139af59c46ca8ddf272ce5da4730954
Parent:        271252eff7bac62c186528ebaee176133eeeabaf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 13 11:04:15 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 13 11:04:15 2014 -0600

lvmcache.7: remove unwanted line continuation syntax

---
 man/lvmcache.7.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 79ceb64..ad31aef 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -88,7 +88,7 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
+.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV
 .br
 .RS
 .B VG/CacheDataLV


