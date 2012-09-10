From: Petr Rockai <prockai@redhat.com>
Date: Mon, 10 Sep 2012 21:56:36 +0200
Subject: [RFC] Towards better scalability: removing lvmcache
Message-ID: <87wr01ps7f.fsf@aldalome.mornfall.net>
	(sfid-20120910_215636_756488_74530BB2)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

below, you will find the first iteration of the "gutting lvmcache"
proposal. I have probably missed some details, but there shouldn't be
many loose ends. It's quite likely that important bits are missing from
the text and only live in my head so far -- please give it a read and
ask questions if anything is not clear.

I don't expect to put much coding work into this for another fortnight
or so, but please do read the RFC soon. I would like to see a consensus
making this a binding plan, and shouting now if you disagree with
something is the best way to avoid being painted into a corner by actual
patches later on.

Yours,
    Petr

Towards better scalability: removing lvmcache
=============================================

Since lvmetad is becoming reasonably solid, it is high time we tackled some of
the scalability problems in LVM that prevent us from making lvmetad more
efficient. While the most obvious issue is the metadata format, we can go a long
way in preparing for a change in that department. The problem with the metadata
format is its granularity / atomicity level, which is a Volume Group. However,
VGs can become very large and since each operation is now linear in the VG size,
performance suffers badly.

While this issue needs to be addressed in many places over the LVM codebase, any
place we would like to start with will run into its lvmcache hooks -- basically,
everything metadata-related in LVM interfaces with lvmcache somehow. I have made
these interfaces more explicit in the past (in preparation to integrating
lvmetad), but that was only a first step. In this RFC, I'll detail a plan to
completely remove lvmcache and therefore internal (sometimes circular)
dependencies that make it hard to change the VG representation.

Currently, lvmcache has the following roles:
- proxying label scans
- caching labels
- maintaining shadow PV structures (lvmcache_info; PV info is split over struct
  physical_volume and lvmcache_info, with a significant overlap)
- maintaining shadow VG structures (lvmcache_vginfo; similar to PV case above)
- proxying VG locks
- proxying access to VG format and to VG/PV format_instances
- maintaining MDA and DA lists

Basically all access to struct VG and struct PV needs to be accompanied with
*some* interface to lvmcache. Sadly, lvmcache does more than cache, and it
cannot be simply dropped by making all its APIs noop (this would have been the
case if it was actually a cache).

Therefore, we must first move all the useful functionality out of lvmcache into
places where it belongs. The proposed solutions:

Label Scans
-----------

scan_pvs: iterate through devices, find labels, build a list; label gains a
mandatory pvid field, while the "pvid" field in device_t is removed (it is a
layering violation anyhow)

scan_vgs: iterate through metadata areas (assembled from lvm.conf and a list of
labels), read metadata and build a list of unique metadata instances

The above two interfaces are STATELESS. They only do what is said above and
nothing else, no info is cached and no global scanner state exists at this
level. The actual implemented interface might be lazy (i.e. obtain a callback to
process each label/mda), to avoid accumulating all the data in memory
uselessly. Nevertheless, the basic idea remains. This scanning interface does NO
LOCKING. An extra per-VG (per-PV) rescan interface is provided to accomodate for
proper locking. See below.

Shadow Structures
-----------------

The most notorious problem of lvmcache is its shadow data structure. A
process-global associative map from PVIDs to lists of lvmcache_info and from
VGIDs to lists of lvmcache_vginfo are maintained. These structures duplicate
parts of struct volume_group and struct physical_volume, and depending on
caching status, also contain entire copies of VG metadata and possibly struct
volume_group.

This structure is part cache and part data store. Initially, I would say the
cache part can be dropped entirely, without significant performance impact. In
the unlikely case that an important scenario is substantially slowed down, we
can re-introduce a proper, separate cache.

The rest of the data needs to be folded into struct volume_group and struct
physical_volume. A pair of super-structures will possibly need to be introduced,
to hold a set of VGs and a set of PVs, for the benefit of various multi-VG and
multi-PV commands.

An appropriate acquisition interface needs to come into place, where we can
request a bunch of PVs/VGs at once. At this time, it seems that the iterators in
toollib.c can be adjusted to use the stateless scanning interface and a "rescan"
interface in combination with proper read locks. When lvmetad is available, the
rescan can be as simple as checking seqno against lvmetad. A single VG read can
grab locks and issue a scan, discarding all but the relevant MDAs (and for
lvmetad systems, just request the metadata from lvmetad).

The DA and MDA lists that are currently tracked by lvmcache need to be folded
into volume_group. The "format_instance" code currently tracks MDA/DA lists, but
it is tied into lvmcache. The whole format_instance concept can be simply
dropped, since a substantial part of it is actually lvmcache glue. Since MDA and
DA are concepts that are meaningful outside of a specific metadata format, DA
and MDA lists should be lifted into struct volume_group. Since we now have an
orphan VG that is available at all times, orphaned MDAs can be simply tracked in
this VG. Both MDAs and DAs should be able to refer to PVs as their backing
storage (in addition to files and/or databases for the case of MDAs).

Miscellaneous changes
---------------------

- format_text is full of lvmcache references, most often due to DA/MDA handling
  all going through lvmcache; there is even a call to lvmcache_label_scan, which
  should be removed -- scanning is a layer *above* metadata format
  implementations, not below
- the lvmetad interface will change, since it currently ties into lvmcache
  (which was necessary because lvmcache funnels all scanning)
- dev-io uses lvmcache to defer closing devices... this seems to be a
  superfluous optimisation and can be removed
- the conflict resolution code as it exists in lvmcache is no longer meaningful
  without a global cache; only VG lookup by name needs to resolve naming
  conflicts and this code can then be shared between lvmetad and scanning-based
  paths

Further work
------------

When the above is done, it should be possible to start adding per LV
interfaces. An interface for scanning (and obtaining lvmetad data) for a single
LV would make it possible to gain significant speedups from lvmetad on many-LV
systems. This will only help for read-only operations, but it is a start. In
those cases, it should be relatively easy to assemble a partial VG structure to
support most of current code. This is somewhat similar to how we treat orphan
VGs. Further down the road, more LV-level code should come, including per-LV
metadata read/write locks and a transactional approach to metadata updates.

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


