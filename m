From: Marcus Müller <mueller@kit.edu>
Date: Wed, 23 Aug 2017 13:29:22 +0200
Subject: [PATCH 1/1] added resizing for btrfs
In-Reply-To: <2c307eee-72f8-7283-6bc0-f7072e652ca2@suse.com>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<20170802174235.19869-2-marcus@hostalia.de>
	<2c307eee-72f8-7283-6bc0-f7072e652ca2@suse.com>
Message-ID: <f65efe40-1f9b-dd94-5ab3-70802ebce6f1@kit.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Eric,

ha! Nearly escaped my memory.

Re: your (justified) objections:

> 1. lack "check" action in your script
> In patch [1], it uses "btrfs scrub", which I think you can replace it
> with "btrfs check".

1. You're right; `btrfs scrub` just checks the file/metadata checksums 
on a live system (and can thus correct /file breakage/), whereas `btrfs 
check` checks for structural damage.

I'm not sure `btrfs scrub` is the right thing to do ? certainly, it will 
detect corrupted blocks; but as far as I can see, these aren't a problem 
at all during resizing; they would be moved untouched.

I'm, on the other hand, also not sure we should implement anything here 
? other filesystem checks are simply skipped if the filesystem is 
already mounted (and mounting is a requirement for resizing). `btrfs 
check` would take a long time.

So, either btrfs check or a nop; either is fine with me, what would you 
prefer?

Then: your code remarks

> +resize_btrfs() {
> +      detect_mounted
> +      MOUNTPOINT=$MOUNTED
> +      if [ -z "$MOUNTED" ]; then
> +            MOUNTPOINT=$TEMPDIR
> +            temp_mount || error "Cannot mount Btrfs filesystem."
> +      fi
> +    verbose "mounted on $MOUNTPOINT"
>
> Indention looks wrong? 
Indeed :) will have to fix that.
> +
> +        line_before="$last_line"
> +        last_line="$i"
> There variables "line_before" and "last_line" look redundant?

err, yes. I had a more complex parser in place for that needed two lines 
of history, but I was able to simplify it. My bad!

Now, I'll have to fix that too.

Thanks for the review!

Marcus

[3] https://btrfs.wiki.kernel.org/index.php/Btrfsck


On 08/23/2017 10:20 AM, Eric Ren wrote:
> Hi Marcus,
>
> I draft a test script [2] for this patch. I've tested our 
> SUSE-specific patch[1] with this test script.
> But, I haven't test your patch yet.
>
> I find two things in your patch, hope you can take another look:
>
> 1. lack "check" action in your script
> In patch [1], it uses "btrfs scrub", which I think you can replace it
> with "btrfs check".
>
> 2. some review comments inline below.
>
> [1] 0001-fsadm-add-support-for-btrfs.patch
> [2] 0002-test-add-fsadm-btrfs.sh.patch
>
> On 08/03/2017 01:42 AM, c M?ller wrote:
>> From: Marcus M?ller <mueller@kit.edu>
>>
>> ---
>>   scripts/fsadm.sh | 69 
>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>>   1 file changed, 68 insertions(+), 1 deletion(-)
>>
>> diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
>> index 459905fc6..7101109e6 100755
>> --- a/scripts/fsadm.sh
>> +++ b/scripts/fsadm.sh
>> @@ -22,6 +22,7 @@
>>   # ext2/ext3/ext4: resize2fs, tune2fs
>>   # reiserfs: resize_reiserfs, reiserfstune
>>   # xfs: xfs_growfs, xfs_info
>> +# btrfs: btrfs
>>   #
>>   # Return values:
>>   #   0 success
>> @@ -41,6 +42,7 @@ TUNE_REISER=reiserfstune
>>   RESIZE_REISER=resize_reiserfs
>>   TUNE_XFS=xfs_info
>>   RESIZE_XFS=xfs_growfs
>> +TOOL_BTRFS=btrfs
>>     MOUNT=mount
>>   UMOUNT=umount
>> @@ -520,6 +522,70 @@ resize_xfs() {
>>       fi
>>   }
>> +###############################################################################
>> +# Resize BTRFS filesystem
>> +# - mounted for upsize
>> +# - mounted for downsize
>> +# - since BTRFS supports multi-volume filesystems, only resize the 
>> btrfs volume
>> +#   we've actually resized
>> +############################################################################### 
>>
>> +resize_btrfs() {
>> +      detect_mounted
>> +      MOUNTPOINT=$MOUNTED
>> +      if [ -z "$MOUNTED" ]; then
>> +            MOUNTPOINT=$TEMPDIR
>> +            temp_mount || error "Cannot mount Btrfs filesystem."
>> +      fi
>> +    verbose "mounted on $MOUNTPOINT"
>
> Indention looks wrong?
>
> Verbose like "$subvolume mounted on $mnt"?
>
>> +
>> +    local old_ifs="$IFS"
>> +    local last_line=""
>> +    local used=""
>> +    local devid=""
>> +    local devid_use=""
>> +    BLOCKSIZE=1
>> +
>> +    unset IFS
>> +      verbose "Parsing $TOOL_BTRFS filesystem show --raw \"$VOLUME\""
>> +      for i in $(LC_ALL=C "$TOOL_BTRFS" filesystem show --raw 
>> "$VOLUME"); do
>> +        case "$last_line" in
>> +            "size")
>> +                BLOCKCOUNT=$i
>> +                ;;
>> +            "used")
>> +                used=$i
>> +                ;;
>> +            "devid")
>> +                devid="$i"
>> +                ;;
>> +            "path")
>> +                if test "$i" = "$VOLUME" ; then
>> +                    verbose "Found $VOLUME; has devid $devid size 
>> $BLOCKCOUNT B"
>> +                    devid_use="$devid"
>> +                fi
>> +                ;;
>> +            esac
>> +
>> +        line_before="$last_line"
>> +        last_line="$i"
> There variables "line_before" and "last_line" look redundant?
>
> Thanks,
> Eric
>
>> +    done
>> +    IFS=old_ifs
>> +
>> +
>> +      validate_parsing "$TOOL_BTRFS"
>> +      decode_size "$BLOCKCOUNT" "$BLOCKSIZE"
>> +      FSFORCE=$FORCE
>> +    if test $(("$used")) -lt $(("$NEWSIZE")) ; then
>> +        verbose "$VOLUME: size $NEWSIZE B >= used $used B"
>> +    else
>> +        verbose "$VOLUME: trying to shrink filesystem to size 
>> $NEWSIZE B, which is less than used $used B"
>> +        verbose "$VOLUME: that might still work on multi-volume Btrfs"
>> +    fi
>> +    verbose "Resizing filesystem on device \"$VOLUME\", mounted on 
>> \"$MOUNTPOINT\" to $NEWSIZE bytes"
>> +    dry "$TOOL_BTRFS" filesystem resize "${devid_use}:${NEWSIZE}" 
>> "$MOUNTPOINT"
>> +
>> +}
>> +
>>   ####################
>>   # Resize filesystem
>>   ####################
>> @@ -536,6 +602,7 @@ resize() {
>>         "ext3"|"ext2"|"ext4") resize_ext $NEWSIZE ;;
>>         "reiserfs") resize_reiser $NEWSIZE ;;
>>         "xfs") resize_xfs $NEWSIZE ;;
>> +      "btrfs") resize_btrfs $NEWSIZE ;;
>>         *) error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not 
>> supported by this tool." ;;
>>       esac || error "Resize $FSTYPE failed."
>>       cleanup 0
>> @@ -612,7 +679,7 @@ test -n "$FSADM_RUNNING" && exit 0
>>     # test some prerequisities
>>   for i in "$TUNE_EXT" "$RESIZE_EXT" "$TUNE_REISER" "$RESIZE_REISER" \
>> -    "$TUNE_XFS" "$RESIZE_XFS" "$MOUNT" "$UMOUNT" "$MKDIR" \
>> +    "$TUNE_XFS" "$RESIZE_XFS" "$TOOL_BTRFS" "$MOUNT" "$UMOUNT" 
>> "$MKDIR" \
>>       "$RMDIR" "$BLOCKDEV" "$BLKID" "$GREP" "$READLINK" \
>>       "$DATE" "$FSCK" "$XFS_CHECK" "$XFS_REPAIR" "$LVM" ; do
>>       test -n "$i" || error "Required command definitions in the 
>> script are missing!"
>


