From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 15 Apr 2009 19:49:42 +0100
Subject: [PATCH 1/4] Udev integration: add LVM fields support for dmsetup
In-Reply-To: <49DC94D2.4010903@redhat.com>
References: <49DC94D2.4010903@redhat.com>
Message-ID: <20090415184942.GL7843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 08, 2009 at 02:13:06PM +0200, Peter Rajnoha wrote:
> +dm_split_lvm_name_mem
>  dm_split_lvm_name

Do we really need both?
(What if mem was NULL in the existing fn?)

> -	DR_TREE = 8	/* Complete dependency tree required */
> +	DR_TREE = 8,	/* Complete dependency tree required */
> +	DR_NAME = 16

So presumably we use a similar trick to what we did in lvm recently for the PV
label fields, where if the user supplies the name (rather than the major/minor
method) and only asks for DM_NAME fields, we skip the ioctls.
If they ask for the prefix though, still use the ioctl - though if it;s already
set in an environment variable and only one device is being requested, that could
take precedence.

Anyway, it's a very minor cleanup, so leave it for now.
  
> +static char *_get_uuid_prefix(const char *uuid)

Maybe _extract_uuid_prefix ?
Does it return a const?

> +	int len;

size_t ?

> +	if (!strcmp(split_name->subsystem, "LVM"))

Is this code no longer supporting on-the-fly updating from a system running
a version of lvm that did not add the prefixes?
If it's too hard to make this code work without them, then we must
document the requirement to reboot immediately after updating and without
manipulating any devices.
It may be better to recommend that people upgrade to an intermediate version
first, then reboot, then upgrade to this version.

> +FIELD_O(NAME, dm_split_name, STR, "Subsystem", subsystem, 10, dm_subsystem, "subsystem", "DM subsystem.")
> +FIELD_O(NAME, dm_split_name, STR, "VGName", vg, 10, dm_vg_name, "vg_name", "LVM volume group name.")
> +FIELD_O(NAME, dm_split_name, STR, "LVName", lv, 10, dm_lv_name, "lv_name", "LVM logical volume name.")
> +FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 10, dm_lv_layer_name, "lv_layer", "LVM layer.")

4 lots of 10 ?
Normally it's related to the size of the column heading used.

Alasdair
-- 
agk at redhat.com


