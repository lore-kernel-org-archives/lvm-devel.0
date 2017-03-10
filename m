From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:34:54 -0500
Subject: master - lvcreate: avoid rejecting --metadataprofile
Message-ID: <201703101834.v2AIYs2k020267@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f221ba97c99c4369714755d636093aa9c6276791
Commit:        f221ba97c99c4369714755d636093aa9c6276791
Parent:        fb38426d289ab010d2083a394dca685eed13e7ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 2 23:02:28 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvcreate: avoid rejecting  --metadataprofile

Likely user normaly have used 'shortcut' --profile option which
is (for lvcreate) decoded as metadataprofile.

However full option was rejected.
---
 tools/lvcreate.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ed56757..206a10b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -762,6 +762,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	contiguous_ARG,\
 	ignoreactivationskip_ARG,\
 	ignoremonitoring_ARG,\
+	metadataprofile_ARG,\
 	monitor_ARG,\
 	mirrors_ARG,\
 	name_ARG,\


