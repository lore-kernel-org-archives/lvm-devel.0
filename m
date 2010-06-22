From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:33 -0400
Subject: [PATCH 00/35] Add full metadata balancing support, v5.
Message-ID: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a fifth round of the metadata balancing support,
makes minor revisions and builds on the fourth round of patches
submitted (5/26/2010).  There are still some definite warts and
FIXMEs in the code but this is now a complete patchset for the
metadata balance feature.

Changes from the fourth round start around patch 19 and include:
1) Sort mdas so that ignored mdas get committed to disk first.
This reduces the time that we may get an inconsistent on-disk
state that would require auto-repair.
2) Fixed a few bugs in pv-based metadata balance patchset.
3) Add "phase 2" (vg-based) of metadata balance.  Define one
function which implements the metadata balancing and call it from
the vg_write() path.  In most cases, this works just fine, but
there are a few checks that need updated for the new 'fid' list
of ignored mdas.
4) Update nightly test cases to include all "phase 2" commands
such as vgcreate, vgchange, vgsplit, etc.



