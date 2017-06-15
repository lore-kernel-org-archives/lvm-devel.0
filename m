From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 15 Jun 2017 12:55:00 +0200
Subject: master - lvconvert: Disallow removal of primary when up-converting (recovering)
In-Reply-To: <201706141342.v5EDg1in012800@lists01.pubmisc.prod.ext.phx2.redhat.com>
References: <201706141342.v5EDg1in012800@lists01.pubmisc.prod.ext.phx2.redhat.com>
Message-ID: <dbd7cec1-0abc-82ce-491b-3338ac24ebe7@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/14/2017 03:42 PM, Jonathan Brassow wrote:
> Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddb14b6b05e0f75a97ab8ab1ed99091268c239ba
> Commit:        ddb14b6b05e0f75a97ab8ab1ed99091268c239ba
> Parent:        4c0e908b0ac012a5517e61420ea1eccc6193c00a
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Wed Jun 14 08:41:05 2017 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Wed Jun 14 08:41:05 2017 -0500
> 
> lvconvert: Disallow removal of primary when up-converting (recovering)
> 
> This patch ensures that under normal conditions (i.e. not during repair
> operations) that users are prevented from removing devices that would
> cause data loss.
> 
> When a RAID1 is undergoing its initial sync, it is ok to remove all but
> one of the images because they have all existed since creation and
> contain all the data written since the array was created.  OTOH, if the
> RAID1 was created as a result of an up-convert from linear, it is very
> important not to let the user remove the primary image (the source of
> all the data).  They should be allowed to remove any devices they want
> and as many as they want as long as one original (primary) device is left
> during a "recover" (aka up-convert).
> 
> This fixes bug 1461187 and includes the necessary regression tests.
> ---

...
> diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
> index e173d66..fba7864 100644
> --- a/test/shell/lvconvert-raid.sh
> +++ b/test/shell/lvconvert-raid.sh
> @@ -223,6 +223,67 @@ for i in 1 2 3 ; do
>   done
>   
>   ###########################################
> +# Upconverted RAID1 should not allow loss of primary
> +#  - don't allow removal of primary while syncing
> +#  - DO allow removal of secondaries while syncing
> +###########################################
> +aux delay_dev $dev2 0 100
> +lvcreate -aey -l 2 -n $lv1 $vg $dev1 $dev2
> +lvconvert -y -m 1 $vg/$lv1 \
> +	--config 'global { mirror_segtype_default = "raid1" }'
> +lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'

Seems there is still some problem.

The following lvconvert is prohibited only with some kernels:

> +not lvconvert --yes -m 0 $vg/$lv1 $dev1

This test correctly passes on RHEL-7.4,

As expected fails on older kernels (e.g. RHEL6) - I suggest to use 
`should not` instead of plain `not` for these, or skip the primary leg 
extraction.

But surprisingly(?) fails, also on rawhide running 4.12-rc5:

#lvconvert-raid.sh:235+ not lvconvert --yes -m 0 @PREFIX at vg/LV1 
@TESTDIR@/dev/mapper/@PREFIX at pv1

   WARNING: This metadata update is NOT backed up.
   Logical volume @PREFIX at vg/LV1 successfully converted.

dmesg saying:

md: recovery of RAID array mdX
md: mdX: recovery interrupted.

-- Martian


