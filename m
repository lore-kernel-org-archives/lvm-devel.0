From: Petr Rockai <prockai@redhat.com>
Date: Mon, 30 Jan 2012 17:50:31 +0100
Subject: [DRAFT PATCH] Client-side LVMetaD integration
In-Reply-To: <874nvwvxuh.fsf@mornfall.net> (Petr Rockai's message of "Mon, 16
	Jan 2012 09:46:30 +0100")
References: <874nvwvxuh.fsf@mornfall.net>
Message-ID: <87fwext9rc.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again!

Petr Rockai <prockai@redhat.com> writes:
> I have a preliminary version (really preliminary, it is full of debug
> junk, excuse me please) of client-side integration of lvmetad. There
> comes an executive summary:

I am attaching a new version that addresses most of the issues outlined
below. I will give more details inline.

> - We do not disable label scanning just yet (which is the major cause of
>   IO hitting disk). We can get there, but two things need to be sorted
>   out first: tracking MDAs (more about that below) and building up
>   lvmcache info structures from lvmetad data. This is required because
>   we are not quite ready to nuke lvmcache right now (but we'll get
>   there, bear with me).

This is still true. There are basically two things that need to happen
to get there:

- better internal handling of orphan PVs (through the orphan VG)
- MDA tracking inside metadata (using PV labels/UUIDs)

> 1. Code fails to notice inconsistencies (VG metadata is cached and not
>    enough manual scanning can happen due to below).
>
>    FAILED: shell/inconsistent-metadata.sh
>    FAILED: shell/unlost-pv.sh

I have changed vgscan to always scan disks and find inconsistencies that
way. It will now also update lvmetad with what it finds on disk. Both
these tests now pass (but inconsistent-metadata needed to be modified to
not expect commands like vgs to notice on-disk inconsistencies).

> 2. Pvscan is not entirely integrated with lvmetad yet. Moreover, even if
>    we fully update the PV status from pvscan (we currently only add PVs,
>    not remove them even if they failed to turn up), there will be a
>    problem that a VG with all PVs missing is currently regarded as
>    existing by lvmetad. This can be fixed (i.e. last PV disappears means
>    the VG ceases to exist), but should be probably discussed first.
>
>    FAILED: shell/lvmcache-exercise.sh

I have compromised on this slightly: VGs will only disappear entirely
when all their PVs were marked missing through a pvscan. This seems to
be a reasonable approach. The test passes now and nothing new broke.

> 3. MDA info is out of band from metadata. Needs to be merged with
>    metadata in lvmetad, otherwise lvmetad can't keep track of this.
>    This will in turn prompt a reform of the format_instance code, which
>    is an utter mess anyway, and needs to be cleaned up ASAP. A central
>    place to obtain the MDA infos is requisite, otherwise we can't
>    disable label scanning.
>
>    FAILED: shell/metadata-balance.sh
>    FAILED: shell/pvcreate-usage.sh
>    FAILED: shell/vgextend-usage.sh

These 3 tests still fail. The MDA info has not been integrated with
metadata yet. I'll work on this next and expect to have a working
version done before FOSDEM starts.

> 4. Wrong format reported (lvm2, but the VG itself is lvm1) due to
>    importing text metadata from lvmetad. Same problem exists with
>    reading text backups of LVM1 VGs, but this is not caught by the
>    testsuite. There is an old FIXME around. Extending LVM2 metadata with
>    a "semantics" version marker saying "this is LVM1 even though you are
>    looking at text metadata" would fix the problem. We can also handle
>    this out of band in lvmetad, but it is inelegant and leaves tho other
>    problem open.
>
>    FAILED: shell/vgcreate-usage.sh

To fix this, I have added an optional field "format" to text-formatted
metadata. It is always produced when the format is known (through the
format instance context). When metadata is obtained from lvmetad, the
format field is used to construct a correct format instance and format
instance context. The relevant test is fixed.

> When all of the above is addressed, plus we can populate lvmcache
> objects from lvmetad, we should be in a position to pull the plug on
> label scans when lvmetad is around. Let's wish for a smooth ride. :-)

This now means basically number 3, and possibly the orphan PV
handling. I'll keep you informed.

Yours,
   Petr

PS: I would like to start merging this code ASAP, since it can be easily
compiled out by default. I fancy that we'll sit down on this with
Alasdair next Monday and get the majority of the changes reviewed and
merged. Flipping the configure switch can wait a bit longer, but when
this is merged we'll be able to add automated builds with lvmetad
enabled to get some more testing coverage.

PPS: I know that the patch is dirty like a zebra. I'll clean it up as
soon as I am finished with deratizing^Wdebugging it. It is a DRAFT for a
reason.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmetad-2.diff
Type: text/x-patch
Size: 47033 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120130/cc568901/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
