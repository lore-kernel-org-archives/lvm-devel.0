From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 04 Oct 2011 19:09:57 +0200
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
	<4E8AD4CF.3080609@redhat.com>
	<alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
Message-ID: <4E8B3DE5.2080803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.10.2011 14:13, Lukas Czerner napsal(a):
> On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
>
>> Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
>>> This commit adds new functionality in the form of new commands. Namely
>>> it is create, list, add and remove. This commit also changes the way how
>>> are commands recognised an executed. The new approach is more suitable
>>> for bigger number of commands.
>>>
>>> Resize command is also significantly reworked. Unlike in the old
>>> approach fsadm will always attempt to resize the logical volume as well,
>>> since this is what it is expected. Leave the --lvresize option for
>>> backwards compatibility, but remove it from the help. If no file system
>>> resides on the logical volume, only the volume will be resized.
>>>
>>> * Create command provides the functionality of creating a new logical
>>>     volumes including defined file system.
>>> * List command provides the functionality of listing useful information
>>>     about the logical volumes, file systems and devices.
>>> * Add command allows to add devices into volume groups (pool).
>>> * Remove command allows to remove the volumes or volume groups from the
>>>     system.
>>>
>>> Signed-off-by: Lukas Czerner<lczerner@redhat.com>
>>
>>> @@ -96,7 +109,6 @@ tool_usage() {
>>>    	echo "    -e | --ext-offline  unmount filesystem before ext2/ext3/ext4
>>> resize"
>>>    	echo "    -f | --force        Bypass sanity checks"
>>>    	echo "    -n | --dry-run      Print commands without running them"
>>> -	echo "    -l | --lvresize     Resize given device (if it is LVM
>>> device)"
>>>    	echo "    -y | --yes          Answer \"yes\" at any prompts"
>>>    	echo
>>>    	echo "  new_size - Absolute number of filesystem blocks to be in the
>>> filesystem,"
>>
>>
>> Again - no way to remove already supported option.
>
> This is only removed from the tool_usage(), as you can see. I am not
> removing it from the code, but only from the documentation since it is
> not needed in the new code.
>

Ok this made it clear that such functional change than needs a separate patch, 
which will demonstrate how it's going to be used and how it is matching 
current behavior.



>>> -	if [ "$DO_LVRESIZE" -eq 2 ]; then
>>> -		# start LVRESIZE with the filesystem modification flag
>>> -		# and allow recursive call of fsadm
>>> -		_FSADM_YES=$YES
>>> -		export _FSADM_YES
>>> -		unset FSADM_RUNNING
>>> -		test -n "$LVM_BINARY"&&   PATH=$_SAVEPATH
>>> -		dry exec "$LVM" lvresize $VERB $FORCE -r -L${NEWSIZE}b
>>> "$VOLUME_ORIG"
>>> -	fi
>>> -
>>
>> Again - please do not remove things you do not understand.
>
> Oh, but I do understand. Please read the new code, before trying to
> insult me. But maybe it would be better to separate resize command
> changes into separate patch.
>
>>
>> And also thing like this needs to be in a separate patch - not bundled in
>> hundreds patch lines.


It's nothing about insulting - this is very tricky change - so unless this is 
extracted to separate patch to be properly reviewed for all combination and 
whether all cases keep all VG locks properly.
(Thus patch needs to explain how it will resize  filesystem and LV when user 
calls fsadm resize and this operation could not be broken with another 
parallel lvm operation in both directions - upsize/downsize while current 
syntax is still usable)


>> Well user is always the master - if he is brave to go without it, let him do
>> what he wants (i.e. destroy his fs).
>
> You're missing the point, resize2fs requires that the file system is
> checked with e2fsck -f prior the resize, if on of the conditions happen
>
> 1. file system was not cleanly umounted
> 2. file system contain errors, or is invalid
> 3. it was not checked since the last time it was mounted
>
> It is just to make sure that the file system is consistent and we will
> not make everything worse by messing with metadata further.
>

If the user wants to risk  resize2fs without fsck - it's his decision (and 
current -f with fsadm allows it) - and since we are not like gnome3 - we allow 
users to kill their systems in number of ways already, so no reason to 
eliminate this one.

i.e. mkfs, mount, umount, resize LV, resize2fs -f   works without fsck and 
makes errorless result - so we support.

Zdenek



