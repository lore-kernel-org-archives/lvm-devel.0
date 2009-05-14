From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 14 May 2009 01:28:22 +0100
Subject: [PATCH v2] vgimportclone: script to import SAN snapshots and clones
In-Reply-To: <1242253944-502-1-git-send-email-snitzer@redhat.com>
References: <1242253944-502-1-git-send-email-snitzer@redhat.com>
Message-ID: <20090514002822.GD25793@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 13, 2009 at 06:32:24PM -0400, Mike Snitzer wrote:
> +\fBvgimportclone\fP \(em Rename VG and change associated VG and PV UUIDs.

Can you find a way to say why without adding many more characters?
I think this description should concentrate more on the 'why'.
  Import & rename duplicated volume group (e.g. a hardware snapshot).

> +vgimportclone \- rename VG and change associated VG and PV UUIDs.

Ditto.

> +is used to rename the VG associated with the specified PV(s) and change the
> +associated VG and PV UUIDs.  These changes avoid duplicate VG(s) and
> +PV(s) once the origin and snapshots are active simultaneously.  The primary
> +application being HW snapshot restore.

Reorder the ideas there to introduce them in a more logical order?

hardware snapshot (for example)...duplicate name/uuids not permitted...so
change and rename

The word 'restore' here makes no sense to me, I'm afraid.

> +.I \-n|\-\-basevgname VolumeGroupName
> +By default the snapshot VG will be renamed to the original name plus a
> +numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
> +to 'test_vg.1').  This option will override the base VG name that is

I'm not keen on the dot in there.  We don't put dots in any other names.
I'm not keen on names like /dev/test_vg.1/lvol01

> +    echo "Usage: ${SCRIPTNAME} [options] disk1 [disk2 ...]"
> +    echo "    -n|--basevgname - Base name for the new volume group(s)"
> +    echo "    -i|--import     - Import any exported volume group(s)"
> +    echo "    -t|--test       - Run in test mode"
> +    echo "    --quiet         - Suppress output"
> +    echo "    -v|--verbose    - Set verbose level"
> +    echo "    -d|--debug      - Set debug level"
> +    echo "    --version       - Display version information"
> +    echo "    -h|--help       - Display this help message"

Can you standardise this a bit?
Not disk1 but PhysicalVolumePath or PhysicalVolume  (we're already inconsistent)
(If we prefer PhysicalVolumePath1 [PhysicalVolumePath2] - I'm not sure - then
we should change it everywhere in the tree.)

> +    "$RM" -r -- "${TMP_LVM_SYSTEM_DIR}"

(I suppose that's OK without -f.)

> +"$LVM" dumpconfig ${LVM_OPTS} | \
> +"$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/cache \
> +                   '/^[[:space:]]*filter/{print ENVIRON["FILTER"];next} \
> +                    /^[[:space:]]*scan/{print "scan = [ \"" DEV "\" ]";next} \
> +                    /^[[:space:]]*cache_dir/{print "cache_dir = \"" CACHE "\"";next} \
> +                    {print $0}' > ${LVMCONF}

Tools do still support the old 'cache' setting but it doesn't really matter if
new stuff doesn't if it's not easy to do.

I hate to go on about security, but have you tested that the script does not
misbehave even when you give it a PV with the nastiest set of characters you
can imagine in it?

Might as well check this in now, anyway, and deal with any more things people file
in-tree.

Alasdair


