From: Petr Rockai <prockai@redhat.com>
Date: Mon, 16 Jan 2012 09:46:30 +0100
Subject: [DRAFT PATCH] Client-side LVMetaD integration
Message-ID: <874nvwvxuh.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have a preliminary version (really preliminary, it is full of debug
junk, excuse me please) of client-side integration of lvmetad. There
comes an executive summary:

- We do not disable label scanning just yet (which is the major cause of
  IO hitting disk). We can get there, but two things need to be sorted
  out first: tracking MDAs (more about that below) and building up
  lvmcache info structures from lvmetad data. This is required because
  we are not quite ready to nuke lvmcache right now (but we'll get
  there, bear with me).

- With lvmetad as the primary source of metadata, *most* of the test
  suite gets through happily. There are the exceptions, sorted into bins
  by problems tripping the test:

1. Code fails to notice inconsistencies (VG metadata is cached and not
   enough manual scanning can happen due to below).

   FAILED: shell/inconsistent-metadata.sh
   FAILED: shell/unlost-pv.sh

2. Pvscan is not entirely integrated with lvmetad yet. Moreover, even if
   we fully update the PV status from pvscan (we currently only add PVs,
   not remove them even if they failed to turn up), there will be a
   problem that a VG with all PVs missing is currently regarded as
   existing by lvmetad. This can be fixed (i.e. last PV disappears means
   the VG ceases to exist), but should be probably discussed first.

   FAILED: shell/lvmcache-exercise.sh

3. MDA info is out of band from metadata. Needs to be merged with
   metadata in lvmetad, otherwise lvmetad can't keep track of this.
   This will in turn prompt a reform of the format_instance code, which
   is an utter mess anyway, and needs to be cleaned up ASAP. A central
   place to obtain the MDA infos is requisite, otherwise we can't
   disable label scanning.

   FAILED: shell/metadata-balance.sh
   FAILED: shell/pvcreate-usage.sh
   FAILED: shell/vgextend-usage.sh

4. Wrong format reported (lvm2, but the VG itself is lvm1) due to
   importing text metadata from lvmetad. Same problem exists with
   reading text backups of LVM1 VGs, but this is not caught by the
   testsuite. There is an old FIXME around. Extending LVM2 metadata with
   a "semantics" version marker saying "this is LVM1 even though you are
   looking at text metadata" would fix the problem. We can also handle
   this out of band in lvmetad, but it is inelegant and leaves tho other
   problem open.

   FAILED: shell/vgcreate-usage.sh

5. Timing issues, most likely tripped up by different timing of the
   operations in presence of lvmetad. Some of the vgchange -an calls
   fail due to still-open LVs (lvmetad itself never opens any devices
   though). Inserting sleep 1 before the deactivation makes the test
   pass.

   FAILED: shell/vgsplit-operation.sh

So that's it. 1 seems to be an improper subtask of 2, 2 is not hard to
hack up (by telling lvmetad to orphan all PVs and feed the live ones
back) although a proper solution may be tricky (the hack is prone to
leave things haywire if crashes happen). 4 shouldn't be very hard. 5 is
*likely* unrelated to lvmetad. That leaves number 3, which needs some
extra work to be done upfront.

When all of the above is addressed, plus we can populate lvmcache
objects from lvmetad, we should be in a position to pull the plug on
label scans when lvmetad is around. Let's wish for a smooth ride. :-)

Yours,
   Petr

PS: I'll try to dig into the MDA issue a bit more to come up with an
attack plan, hopefully it won't be very hard. Then I'll probably revisit
the lvmcache separation work, which could be useful in the "populate
lvmcache" part of the deal.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmetad-1.diff
Type: text/x-patch
Size: 28202 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120116/55bb9b0d/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
