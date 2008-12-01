From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 1 Dec 2008 13:30:44 +0000
Subject: [PATCH] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1228072273-8119-1-git-send-email-dwysocha@redhat.com>
References: <1228055977.3315.21.camel@localhost.localdomain>
	<1228072273-8119-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081201133044.GA26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Nov 30, 2008 at 02:11:13PM -0500, Dave Wysochanski wrote:
> With this update, the user may opt to skip pvcreate, provided the default
> values of pvcreate are adequate.  If the user wants some non-default value
> in the PV (e.g. 0 metadatacopies, etc), pvcreate must be used prior to
> vgcreate/vgextend.
 
Look at each of the pvcreate command line options and try to offer them as part
of vgcreate and vgextend.  They will only be used for devices that are not
already PVs and inside the VG.

vgcreate
        [--addtag Tag]   
	  - will continue to add a VG tag not a PV tag (because the command
	    name starts with vg)
	If there's a need for both in future we can add --addpvtag and --addvgtag.

pvcreate args:
    Add to both vgcreate & vgextend:
        [-f[f]|--force [--force]] 
        [-y|--yes]
	    - trivial

        [--labelsector sector] 
        [--metadatasize MetadataSize[kKmMgGtTpPeE]]
	    - unambiguous

        [--metadatacopies #copies]
	    - ambiguous: Does it mean number of copies on each disk or number
	      of copies in total in the VG?
	Solution: add --pvmetadatacopies to pvcreate, vgcreate & vgextend 
	In future we can add --vgmetadatacopies to vgcreate & vgextend.
	--metadatacopies will be the same as --pvmetadatacopies in pv* commands and
	--vgmetadatacopies in vg* commands.  Code it ready to work like that, i.e.
	change the existing code to use pvmetadatacopies_ARG everywhere
	internally, and use _merge_synonym() based on the first 2 chars of the
	command (hard-coded).

        [-Z|--zero {y|n}]
	   - potentially ambiguous: Does it mean zero the VG itself?
	But it's already ambiguous and the only way to find out what it does is to
	read the man page definition.  Zeroing the VG would have no impact or use
	within LVM, so we can leave it doing just what it does today to new PVs.

    Don't add to vgcreate & vgextend - leave these as pv-only for now:  (We can add
    them in an extended way eventually.)
        [--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]
	    - main use is for testing so leave as pvcreate only

        [--restorefile file]
        [-u|--uuid uuid] 
	    - only required in recovery situations


After these changes, the only necessary use of pvcreate will be in recovery
situations.  In future, we'll sort out those remaining recovery options,
then require a vgname (defaulting to an explicit per-metadata-type orphan vg)
always to be given with pvcreate so that every PV belongs to a VG and make
pvcreate a synonym for vgcreate.


Alasdair
-- 
agk at redhat.com


