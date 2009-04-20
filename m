From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 20 Apr 2009 12:37:22 +0200
Subject: [PATCH 1/4] Udev integration: add LVM fields support for dmsetup
In-Reply-To: <20090415184942.GL7843@agk.fab.redhat.com>
References: <49DC94D2.4010903@redhat.com>
	<20090415184942.GL7843@agk.fab.redhat.com>
Message-ID: <49EC5062.8040009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/2009 08:49 PM, Alasdair G Kergon wrote:
> On Wed, Apr 08, 2009 at 02:13:06PM +0200, Peter Rajnoha wrote:
>> +dm_split_lvm_name_mem
>>  dm_split_lvm_name
> 
> Do we really need both?

I think, I added this, because I could not access usable dm_pool
memory here so it could be used with dm_split_lvm_name directly.
I created more general dm_split_lvm_name_mem which is not bound to
dm_pool but can use any block of memory instead. Yes, it's a little
bit strange, I admit. But is there a way I can use a dm_pool in this
context ("_display_info_cols" function)?

> (What if mem was NULL in the existing fn?)
> 
>> -	DR_TREE = 8	/* Complete dependency tree required */
>> +	DR_TREE = 8,	/* Complete dependency tree required */
>> +	DR_NAME = 16
> 
> So presumably we use a similar trick to what we did in lvm recently for the PV
> label fields, where if the user supplies the name (rather than the major/minor
> method) and only asks for DM_NAME fields, we skip the ioctls.
> If they ask for the prefix though, still use the ioctl - though if it;s already
> set in an environment variable and only one device is being requested, that could
> take precedence.

Yes, I'll add this. But we don't have to use ioctl with the UUID prefix either.
It could be read from /sys dir and given as input to dmsetup directly, too. So we
can make a "split-this-uuid" just like we want to do for the DM name. So I think
we can avoid ioctls altogether in here.

>> +	if (!strcmp(split_name->subsystem, "LVM"))
> 
> Is this code no longer supporting on-the-fly updating from a system running
> a version of lvm that did not add the prefixes?
> If it's too hard to make this code work without them, then we must
> document the requirement to reboot immediately after updating and without
> manipulating any devices.
> It may be better to recommend that people upgrade to an intermediate version
> first, then reboot, then upgrade to this version.

hmmm...

>> +FIELD_O(NAME, dm_split_name, STR, "Subsystem", subsystem, 10, dm_subsystem, "subsystem", "DM subsystem.")
>> +FIELD_O(NAME, dm_split_name, STR, "VGName", vg, 10, dm_vg_name, "vg_name", "LVM volume group name.")
>> +FIELD_O(NAME, dm_split_name, STR, "LVName", lv, 10, dm_lv_name, "lv_name", "LVM logical volume name.")
>> +FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 10, dm_lv_layer_name, "lv_layer", "LVM layer.")
> 
> 4 lots of 10 ?
> Normally it's related to the size of the column heading used.

Yes :) I just didn't know the relation here, the exact size, so I did not bother much. I left it as the
last thing to do. Apparently, I forgot to look at it once again.

Peter


