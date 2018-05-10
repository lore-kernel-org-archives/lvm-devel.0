From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:51 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201805101205.w4AC5pgg032550@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b96bb403c3aabe7c1593a87c07e774d9256e790
Commit:        2b96bb403c3aabe7c1593a87c07e774d9256e790
Parent:        2ae4a04710bb2d66a4b7c2d10e56750858f08f04 38f33251b182fdf4a1963dcd249d8d77ab6357ad
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 13:02:27 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 13:02:27 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 doc/lvm-disk-reading.txt       |   42 +++++++++++++++++++++++++++++++
 lib/label/label.c              |   53 +++++++++++++++++++++++++++++++---------
 lib/label/label.h              |    7 +++--
 lib/locking/lvmlockd.c         |   11 ++------
 lib/metadata/lv_manip.c        |   22 ++++++++++-------
 lib/metadata/metadata-liblvm.c |   10 +-------
 6 files changed, 104 insertions(+), 41 deletions(-)


