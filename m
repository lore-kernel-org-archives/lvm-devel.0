From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 13 Nov 2014 17:08:03 +0000 (UTC)
Subject: master - lvmcache: remove unnecessary line break syntax
Message-ID: <20141113170803.DEB48614F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01bbbc27bf7734ca81fa4dba6a497af1d8a66ad3
Commit:        01bbbc27bf7734ca81fa4dba6a497af1d8a66ad3
Parent:        474c6a527139af59c46ca8ddf272ce5da4730954
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 13 11:07:34 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 13 11:07:34 2014 -0600

lvmcache: remove unnecessary line break syntax

---
 man/lvmcache.7.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index ad31aef..24ce5b4 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -89,7 +89,6 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
 .B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV
-.br
 .RS
 .B VG/CacheDataLV
 .RE


