From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 17 Aug 2016 19:56:32 +0000 (UTC)
Subject: master - man: lvconvert mention required option
Message-ID: <20160817195632.2138F614B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c71fc1cc21272c8b9e8828b0c6962fd06ec3949
Commit:        8c71fc1cc21272c8b9e8828b0c6962fd06ec3949
Parent:        0336b418281b6ea5b7972e90e5b125b624b1793f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 17 14:56:01 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 17 14:56:01 2016 -0500

man: lvconvert mention required option

---
 man/lvconvert.8.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 175a50c..bc4af80 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -611,6 +611,9 @@ VG/ThinPoolLV
 Convert the data portion of ThinPoolLV to type cache.
 .br
 \[bu]
+Requires \-\-cachepool to specify the cache pool to use.
+.br
+\[bu]
 Operates on the data sub LV of the thin pool LV.
 .br
 \[bu]


