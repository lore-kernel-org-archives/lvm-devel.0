From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 2 Aug 2018 02:23:31 -0400
Subject: 2018-06-01-stable - Merge branch '2018-06-01-stable' of git://sourceware.org/git/lvm2 into 2018-06-01-stable
Message-ID: <201808020623.w726NVix010249@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ebc745f53a12848012c3345571a67bc9cd59cf7
Commit:        3ebc745f53a12848012c3345571a67bc9cd59cf7
Parent:        acd2c6f256077f07e3f8d34b2b824bf2b6b3dc8a a75eb8d74c367b88d5b323d5dfb2e6556f2ad680
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 2 08:08:51 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 2 08:08:51 2018 +0200

Merge branch '2018-06-01-stable' of git://sourceware.org/git/lvm2 into 2018-06-01-stable

* '2018-06-01-stable' of git://sourceware.org/git/lvm2:
  vgcreate: close exclusive fd after pvcreate

 lib/label/label.c |    6 +++---
 tools/toollib.c   |    7 +++++++
 2 files changed, 10 insertions(+), 3 deletions(-)


