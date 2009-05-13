From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 13 May 2009 03:33:33 +0100
Subject: [PATCH] vgimportclone: script to import SAN snapshots and clones
In-Reply-To: <1242168445-30898-1-git-send-email-snitzer@redhat.com>
References: <1242168445-30898-1-git-send-email-snitzer@redhat.com>
Message-ID: <20090513023333.GD10652@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 12, 2009 at 06:47:25PM -0400, Mike Snitzer wrote:
> Revised vgimportclone that should be ready for inclussion in the LVM2
> tree.  Is installed as 'vgimportclone' and a man page is provided.
 
> +vgimportclone \- restore hardware snapshot

restore ?

Better to describe what it actually does.

> +[\-n VolumeGroupName]
> +[\-l LvmConfigFile]
> +[\-i]
> +[\-h]

Can we ensure the parameters are in line with the rest of the tools?
What are the long forms for those names?  (All one-character options should
have verbose forms too.)

Is this really optional (indicated by square brackets)?  Can we make it compulsory?
(As we do in some other tools, even when we can work it out.)
Then it can be positional and not need -n.
- I don't think any tools use -n for VG name.

> +.SH DESCRIPTION
> +.B vgimportclone
> +renames the VG and changes the associated VG and PV UUIDs.

Longer description?
'changes' to what?

Why would anyone use this script?

> +.I \-l LvmConfigFile

I don't think we use 'Lvm' capitalised like that anywhere.
What is this parameter for?
If we add it, what other tools might also want to use it and might
-l already be in use?

> +The template for the config that is used during the VG rename and UUID changes.

Template?  Explain.

> +.TP
> +.I \-i
> +Import exported Volume Groups.

Explain.

> +.I \-h
> +Print help message

No need in the current style - covered by lvm(8), which should be referenced.
It should be added to the command list on lvm(8) too.

Make sure --version -v and -d and --quiet and -t are accepted too (and passed
to any lvm cmds run where appropriate).

> +.SH ENVIRONMENT VARIABLES
> +.TP
> +\fBLVM_BINARY\fP 
> +The LVM2 binary to use.
> +Defaults to "lvm".

Need to support LVM_SYSTEM_DIR - referenced in lvm(8).

Have an EXAMPLE section too.

> +# vgimportclone: This script is used to rename the VG and change the associated
> +#                VG and PV UUIDs (primary application being HW snapshot restore)

Oops - that comment is better than the man page:-)

> +function usage {
> +### display usage message
> +    echo "${SCRIPTNAME} - Restore LVM data from a hardware snapshot"
> +    echo -e "Usage: ${SCRIPTNAME} [options] disk1 [disk2 ...]"
> +    echo -e "\t\t-h\t\t- Display this usage message"
> +    echo -e "\t\t-i\t\t- Import any exported volume groups found"
> +    echo -e "\t\t-n\t\t- Name for the new volume group(s)"
> +    echo -e "\t\t-l [path]\t- location of lvm.conf (default ${LVMCONF})"
> +    exit 0
> +}

Inconsistent with man page...brackets, abbreviations, descriptions etc.

> +        -d)

See above.

> +            DEBUG=1

increment?

> +            exec 2> ./${SCRIPTNAME}.log

Errr ./ ???  What directory are we in and what file might we be clobbering?
(Security blocker.)  Better to retain output from earlier runs too and
ensure there's a timestamp of the run somewhere (cf. lvmdump).

> +        -l)
> +            LVMCONF="$2"; shift; shift

Do we even need that arg if we have LVM_SYSTEM_DIR?

> +"$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/cache \
> +                   '/^[[:space:]]*filter/{print ENVIRON["FILTER"];next} \
> +                    /^[[:space:]]*scan/{print "scan = [ \"" DEV "\" ]";next} \
> +                    /^[[:space:]]*cache_dir/{print "cache_dir = \"" CACHE "\"";next} \
> +                    {print $0}' < ${LVMCONF} > ${TMP_LVM_SYSTEM_DIR}/lvm.conf

What if lvm.conf imports other config files?
We can only ever accept config *directories* as arguments, for that reason.
Better to use 'dumpconfig' I reckon if the intent is to replicate existing configuration
then change a few values.

> +"${LVM}" pvscan

Use vgscan not pvscan.

> +"${LVM}" vgmknodes

That's a built-in option to vgscan.

Alasdair


