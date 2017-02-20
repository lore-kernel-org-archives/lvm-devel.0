From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 23:06:36 +0000 (UTC)
Subject: master - man lvcreate: add special option notes at the start
Message-ID: <20170220230636.32E676134D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2d2cd8777ea0f387383743ba2739007ef1b3baf
Commit:        a2d2cd8777ea0f387383743ba2739007ef1b3baf
Parent:        2396c506890e62da5d13c4f3bcd1f715272ab382
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 15:17:10 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 15:36:30 2017 -0600

man lvcreate: add special option notes at the start

The --name, --size, --extents options deserve a special
note at the start of the man page, before appearing in
the usage section.
---
 man/lvcreate.8.des |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/man/lvcreate.8.des b/man/lvcreate.8.des
index e18affe..488dab4 100644
--- a/man/lvcreate.8.des
+++ b/man/lvcreate.8.des
@@ -26,3 +26,14 @@ virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 
+.SS Usage notes
+
+In the usage section below, \fB--size\fP \fINumber\fP can be replaced
+in each case with \fB--extents\fP \fINumberExtents\fP.  Also see both
+descriptions the options section.
+
+In the usage section below, \fB--name\fP is omitted from the required
+options, even though it is typically used.  When the name is not
+specified, a new LV name is generated with the "lvol" prefix and a unique
+numeric suffix.  Also see the description in the options section.
+


