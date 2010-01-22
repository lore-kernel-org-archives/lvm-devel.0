From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 22 Jan 2010 08:41:50 -0500
Subject: RFC: Summary thoughts on mda balancing, liblvm pv handling, etc
Message-ID: <1264167710.2465.12.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Recently I've been working on metadata balancing as reported by rhbz
426147 and this led to some other possible refactorings and liblvm
thoughts.  I've tried to summarize below.  Any comments appreciated.

1. In preliminary tests, disabling metadata areas (via --metadatacopies 0)
did not provide a huge win for the performance of 'pvs'. I measured 100 pvs
with all pvs containing metadata, then half of them without, and saw pvs
take 14s vs 12s with 50 mdas.  Since the original bz was all about pvs
performance, it is important to make sure mda balancing will truly solve
the problem.  Thus, it might be worthwhile to profile and refactor pvs
in other ways to address the issue.  For example, there are places where
we are clearly reading the same area of the disk multiple times for each
pv just because the code is structured a certain way (see FIXME about
reading the label multiple times).

2. As far as the design of managing the list of mdas, one solution is to change
the 'filler' field in raw_locn to 'flags' and make a non-zero flag for a 
disabled mda.  Then as we read off the disk, we can just not add the mda to
the various 'info' and/or 'vg->fid->metadata_areas' lists.  This means we
need to store the mda_header somewhere though, attached to probably the
pv handle, vg handle, or lvmcache.  This is where I begun to see some of the
refactoring possibilties and where some of intent of the existing design
was unclear.

3. Regarding mdas and the related code structures, it's not entirely clear
why the code is abstracted the way it is.  For example, why are we passing
an 'mdas' list to pv_read(), pv_write(), etc, instead of having a list as
a member of struct physical_volume (attached directly to the pv handle).
I mostly follow the abstractions, and can see we store a list of the mdas
in the 'info' struct, and if the pv is in a vg, a list of mdas attached
to the 'fid' via 'fid->metadata_areas'.  It's unclear why the code is this
way and/or if it is desireable to leave it that way.  While these
constructs are peripheral to the main purpose of this change, they are
related so I've started refactoring some of these areas.

4. The orphan pv vs non-orphan pv handling looks messy and there are FIXMEs
in pvchange about locking.  Also, I cannot imagine for liblvm I'd want to
export both 'vg_write' and 'pv_write', and make the application call
'is_orphan' to decide which one to call, the equivalent of pvchange today.
Thus, I also wonder about refactoring pvchange so we have something like:

For obtaining the pv handle:
Option 1: Define a 'pv_open' function which implicitly takes a vg lock
pv = pv_open(path, mode); /* implicit vg lock taken, attached to vg */
if (mdas_disabled)
	pv_set_mdas_disabled(pv, mdas_disabled);

Option 2: Require a user to 'vg_open' with the orphan VG name or a real VG name
(I'm not sure if I like this option b/c it is more function calls
but might be easier to implement.)
vgname = vgname_from_pv_name(path); /* obtained from non-locked lvmcache info */
vg = vg_open(vgname, mode);
pv = pv_from_vg(vg);
if (mdas_disabled)
	pv_set_mdas_disabled(pv, mdas_disabled);

For committing to disk:
vg = vg_from_pv(pv);
vg_write(vg); vg_commit(vg);

_or_

pv_write(pv); pv_commit(pv);




