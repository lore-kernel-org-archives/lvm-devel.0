From: Marian Csontos <mcsontos@redhat.com>
Date: Wed, 7 Jun 2017 14:51:47 +0200
Subject: master - lvconvert: Don't require a 'force' option during RAID repair.
In-Reply-To: <201706061545.v56FjE9p005020@lists01.pubmisc.prod.ext.phx2.redhat.com>
References: <201706061545.v56FjE9p005020@lists01.pubmisc.prod.ext.phx2.redhat.com>
Message-ID: <6cfdc22c-191f-4cf8-c3c6-57fa0c546b72@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With this change applied, older kernels (7.2, RHEL6.x, F21) upconverting 
linear to RAID1 now fails:

#lvchange-raid.sh:132+ lvconvert -y --type raid1 -m 1 @PREFIX at vg/LV1 
/dev/mapper/@PREFIX at pv2
device-mapper: raid: Device 1 specified for rebuild: Clearing superblock
device-mapper: raid: 'rebuild' devices cannot be injected into an array 
with other first-time devices
device-mapper: table: 253:10: raid: Unable to assemble array: Invalid 
superblocks
device-mapper: ioctl: error adding target to table
device-mapper: reload ioctl on  (253:10) failed: Invalid argument
   Failed to lock logical volume @PREFIX at vg/LV1.


Is this expected and should we skip these tests, or is there something 
else going on?

-- Martian

On 06/06/2017 05:45 PM, Jonathan Brassow wrote:
> Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acaf3a5d47fd65b2e385a516544f8e6ec8d89b2d
> Commit:        acaf3a5d47fd65b2e385a516544f8e6ec8d89b2d
> Parent:        88e649628863e78b101c584c513053fc9461c24d
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Tue Jun 6 10:43:49 2017 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Tue Jun 6 10:43:49 2017 -0500
> 
> lvconvert:  Don't require a 'force' option during RAID repair.
> 
> Previously, we were treating non-RAID to RAID up-converts as a "resync"
> operation.  (The most common example being 'linear -> RAID1'.)  RAID to
> RAID up-converts or rebuilds of specific RAID images are properly treated
> as a "recover" operation.
> 
> Since we were treating some up-convert operations as "resync", it was
> possible to have scenarios where data corruption or data loss were
> possibilities if the RAID hadn't been able to sync completely before a
> loss of the primary source devices.  In order to ensure that the user took
> the proper precautions in such scenarios, we required a '--force' option
> to be present.  Unfortuneately, the force option was rendered useless
> because there was no way to distiguish the failure state of a potentially
> destructive repair from a nominal one - making the '--force' option a
> requirement for any repair!
> 
> We now treat non-RAID to RAID up-converts properly as "recover" operations.
> This eliminates the scenarios that can potentially cause data loss or
> data corruption; and this eliminates the need for the '--force' requirement.
> This patch removes the requirement to specify '--force' for RAID repairs.
> ---
>   lib/metadata/raid_manip.c |   31 +------------------------------
>   1 files changed, 1 insertions(+), 30 deletions(-)
> 
> diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
> index 7e55530..08df32c 100644
> --- a/lib/metadata/raid_manip.c
> +++ b/lib/metadata/raid_manip.c
> @@ -379,23 +379,6 @@ int lv_raid_in_sync(const struct logical_volume *lv)
>   	return _raid_in_sync(lv);
>   }
>   
> -/* Check if RaidLV @lv is synced or any raid legs of @lv are not synced */
> -static int _raid_devs_sync_healthy(struct logical_volume *lv)
> -{
> -	char *raid_health;
> -
> -	if (!_raid_in_sync(lv))
> -		return 0;
> -
> -	if (!seg_is_raid1(first_seg(lv)))
> -		return 1;
> -
> -	if (!lv_raid_dev_health(lv, &raid_health))
> -		return_0;
> -
> -	return (strchr(raid_health, 'a') || strchr(raid_health, 'D')) ? 0 : 1;
> -}
> -
>   /*
>    * _raid_remove_top_layer
>    * @lv
> @@ -2908,20 +2891,8 @@ static int _raid_extract_images(struct logical_volume *lv,
>   			if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) &&
>   			    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
>   				continue;
> -
> -			/*
> -			 * Kernel may report raid LV in-sync but still
> -			 * image devices may not be in-sync or faulty.
> -			 */
> -			if (!_raid_devs_sync_healthy(lv) &&
> -			    (!seg_is_mirrored(seg) || (s == 0 && !force))) {
> -				log_error("Unable to extract %sRAID image"
> -					  " while RAID array is not in-sync%s.",
> -					  seg_is_mirrored(seg) ? "primary " : "",
> -					  seg_is_mirrored(seg) ? " (use --force option to replace)" : "");
> -				return 0;
> -			}
>   		}
> +
>   		if (!_extract_image_components(seg, s, &rmeta_lv, &rimage_lv)) {
>   			log_error("Failed to extract %s from %s.",
>   				  display_lvname(seg_lv(seg, s)),
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


