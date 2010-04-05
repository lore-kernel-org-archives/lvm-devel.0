From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:34 -0400
Subject: [PATCH 0/5] Add pv->vg link, v2
Message-ID: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset refactors and adds a pv->vg link.  The previous patchset
missed a few cases, namely vgsplit, vgmerge, vgrename, and format1 code.
This patcheset I believe addresses all cases.  I dropped the lvm2app
patches that utilize this link for pv/vg/lv properties - will be submitted
in another patchset.

It would be nice to refactor further if possible, in particular
the pv->vgname should probably be set inside the add_pvl_to_vgs()
function or something similar, but for now this refactoring is
a step in the right direction.

Although the testsuite is still failing on the latest commits,
these patches passed the testsuite when rebased on the following commit:
commit f9554c7d27930d2ad404b4473ec13aa77f0e53d0
Author: Mike Snitzer <snitzer@redhat.com>
Date:   Wed Mar 24 22:25:11 2010 +0000

    Revert having clvmd consult the lvm.conf "activation/monitoring".
    Correctly implementing the intent of this change requires more
    analysis.



