From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  8 Aug 2016 18:08:18 +0000 (UTC)
Subject: master - man: minor fixes to dmstats.8.in
Message-ID: <20160808180818.EC20B60E02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bcbcdb1a2f276b8139ae0ee7f66ffb342c03f23
Commit:        4bcbcdb1a2f276b8139ae0ee7f66ffb342c03f23
Parent:        175e0905d5e18fe0f3c6f00cdd0eefcefe8eaa3a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 8 19:06:40 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 8 19:07:56 2016 +0100

man: minor fixes to dmstats.8.in

Remove obsolete reference to '--target'.
---
 man/dmstats.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 161ae8c..befc0d5 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -509,7 +509,7 @@ regions (with the exception of in-flight IO counters).
 Creates one or more new statistics regions on the specified device(s).
 
 The region will span the entire device unless \fB\-\-start\fP and
-\fB\-\-length\fP or \fB\-\-target\fP are given. The \fB\-\-start\fP and
+\fB\-\-length\fP or \fB\-\-segments\fP are given. The \fB\-\-start\fP an
 \fB\-\-length\fP options allow a region of arbitrary length to be placed
 at an arbitrary offset into the device. The \fB\-\-segments\fP option
 causes a new region to be created for each target in the corresponding


