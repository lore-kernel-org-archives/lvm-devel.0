From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 11:51:45 -0400
Subject: [PATCH 0/3] Add infrastructure for cleaner pv handling, v2
Message-ID: <1268841108-19327-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This is the second version of the patchset that adds infrastructure
to move us more towards the goal of removing the standalone PV object.

>From now on, a get/set of a PV property from the pvname requires
a lookup of the vgname, then a vg handle from the vgname, a
pv from the vg handle, and finally using the pv handle to get/set
the property.

The last patch reworks pvchange to use this new functionality.
It passes the testsuite but does have at least one bug.  A
setup with a VG containing a PV with metadatacopies == 0 and
pvchange -u --all end up failing because the PV is on both the
orphan VG and the real VG.  I tried a few ways of working around
this, including processing the non-orphan VGs first, but I believe
the root problem lies in the vg locking and lvmcache.
The lvmcache gets invalidated after each vg lock change, so even
if a PV with metadata copies was known to be in a real VG, once
that lock is dropped the cache is invalidated and the PV shows up
in the vg->pvs list for the orphan VG.


