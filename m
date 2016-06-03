From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jun 2016 10:47:21 +0000 (UTC)
Subject: master - man: fixed typo in lvcreate.8
Message-ID: <20160603104721.52E8860507@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68e097972462e3c7c208ac34c62e737b161dd3c4
Commit:        68e097972462e3c7c208ac34c62e737b161dd3c4
Parent:        8e4db009b8f215cb7f593f4b76a6f4bd4293e2ca
Author:        Tobias Stoeckmann <tobias@stoeckmann.org>
AuthorDate:    Mon May 30 23:13:40 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 3 12:46:47 2016 +0200

man: fixed typo in lvcreate.8

It's supposed to be "smaller than" instead of "smaller then".
---
 man/lvcreate.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 8614cb1..c28bc41 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -261,7 +261,7 @@ and the default value is 4KiB.
 For cache pools the value must a multiple of 32KiB
 between 32KiB and 1GiB. The default is 64KiB.
 When the size is specified with volume caching, it may not be smaller
-then cache pool creation chunk size was.
+than cache pool creation chunk size was.
 .br
 For thin pools the value must be a multiple of 64KiB
 between 64KiB and 1GiB.


