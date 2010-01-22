From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Jan 2010 08:25:30 -0500
Subject: [PATCH 0/5]: RFC - Add infrastructure for metadata balancing.
Message-ID: <1264166735-32697-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset is a start towards metadata balancing by introducing
--metadatadisable to pvchange as well as new fields to vgs and pvs
to count the number of disabled mdas.

The disable/enable is implemented at the low level by taking advantage
of the 'filler' field in the mda_header structure on disk.  Normally
this is written to 0, but I propose we change this 32-bit field to
a 'flags' field and then define one flag that is a MDA disable.

This code works for orphan pvs but not yet for pvs in vgs (see
FIXME in the code).  I am somewhat undecided about possible
refactorings in this regard.

Applies cleanly and tested on top of latest upstream:
commit 8e44e884a2b5430097c33641fd155fdf3ff4213c
Author: Alasdair Kergon <agk@redhat.com>
Date:   Fri Jan 22 01:09:09 2010 +0000

    post-release


