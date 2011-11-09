From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 09 Nov 2011 11:56:45 +0100
Subject: [PATCH 2/2] dev names: Add "--names" switch to dmsetup to show names instead of major:minor pairs for deps and ls commands
In-Reply-To: <4EB7D3EB.6000102@redhat.com>
References: <4EB7D3EB.6000102@redhat.com>
Message-ID: <4EBA5C6D.2060604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.11.2011 13:49, Peter Rajnoha napsal(a):
> This makes it a little bit more user-friendly for admins
> if they read the output so they don't need to look for
> the names themselves.
> 
> (there's also an RFE filed here: https://bugzilla.redhat.com/show_bug.cgi?id=731785).
> 
> An example with mirror volume:
> 
> [0] rawhide/~ # dmsetup deps
> vg-lvol0: 3 dependencies	: (253, 2) (253, 1) (253, 0)
> vg-lvol0_mimage_1: 1 dependencies	: (8, 16)
> vg-lvol0_mimage_0: 1 dependencies	: (8, 0)
> vg-lvol0_mlog: 1 dependencies	: (8, 128)
> 
> [0] rawhide/~ # dmsetup deps --names
> vg-lvol0: 3 dependencies	: (vg-lvol0_mimage_1) (vg-lvol0_mimage_0) (vg-lvol0_mlog)
> vg-lvol0_mimage_1: 1 dependencies	: (sdb)
> vg-lvol0_mimage_0: 1 dependencies	: (sda)
> vg-lvol0_mlog: 1 dependencies	: (sdi)

I think, we are mixing /dev  names  and  internal dm names with same symbol
(). So maybe we could use {} for dm names, and  ()  for real /dev
{vg-lvol0_mimage_1} (dm-3)

Or an options   --dmnames could be used if the user really want to see them
translated to dm table names. Maybe option --uuid  could be supported as well
to print uuid device names (like we have  dmsetup ls --tree -o uuid)


> 
> 
> [0] rawhide/~ # dmsetup ls
> vg-lvol0	(253, 3)
> vg-lvol0_mimage_1	(253, 2)
> vg-lvol0_mimage_0	(253, 1)
> vg-lvol0_mlog	(253, 0)
> 
> [0] rawhide/~ # dmsetup ls --names
> vg-lvol0	(dm-3)
> vg-lvol0_mimage_1	(dm-2)
> vg-lvol0_mimage_0	(dm-1)
> vg-lvol0_mlog	(dm-0)
> 
> 
> [0] rawhide/~ # dmsetup ls --tree
> vg-lvol0 (253:3)
>  ??vg-lvol0_mimage_1 (253:2)
>  ?  ?? (8:16)
>  ??vg-lvol0_mimage_0 (253:1)
>  ?  ?? (8:0)
>  ??vg-lvol0_mlog (253:0)
>     ?? (8:128)
> [0] rawhide/~ # dmsetup ls --tree --names
> 
> vg-lvol0 (dm-3)
>  ??vg-lvol0_mimage_1 (dm-2)
>  ?  ?? (sdb)
>  ??vg-lvol0_mimage_0 (dm-1)
>  ?  ?? (sda)
>  ??vg-lvol0_mlog (dm-0)
>     ?? (sdi)
> 

Hmm RFE :) would be nice to have this supported with -C columns, so dm device
names would appear nicely aligned.


> 
> Peter
> ---
>  tools/dmsetup.c |   51 +++++++++++++++++++++++++++++++++++++++------------
>  1 files changed, 39 insertions(+), 12 deletions(-)
> 
> diff --git a/tools/dmsetup.c b/tools/dmsetup.c
> index f35c8a5..0430772 100644
> --- a/tools/dmsetup.c
> +++ b/tools/dmsetup.c
> @@ -130,6 +130,7 @@ enum {
>  	MINOR_ARG,
>  	MODE_ARG,
>  	NAMEPREFIXES_ARG,
> +	NAMES_ARG,
>  	NOFLUSH_ARG,
>  	NOHEADINGS_ARG,
>  	NOLOCKFS_ARG,
> @@ -1767,6 +1768,7 @@ static int _deps(CMD_ARGS)
>  	struct dm_task *dmt;
>  	struct dm_info info;
>  	char *name = NULL;
> +	char dev_name[PATH_MAX];
>  
>  	if (names)
>  		name = names->name;
> @@ -1813,10 +1815,17 @@ static int _deps(CMD_ARGS)
>  		printf("%s: ", name);
>  	printf("%d dependencies\t:", deps->count);
>  
> -	for (i = 0; i < deps->count; i++)
> -		printf(" (%d, %d)",
> -		       (int) MAJOR(deps->device[i]),
> -		       (int) MINOR(deps->device[i]));
> +	for (i = 0; i < deps->count; i++) {
> +		if (_switches[NAMES_ARG] &&
> +		    dm_device_get_name((uint32_t) MAJOR(deps->device[i]),
> +				       (uint32_t) MINOR(deps->device[i]),
> +				       0, dev_name, PATH_MAX))
> +			printf(" (%s)", dev_name);
> +		else
> +			printf(" (%d, %d)",
> +			       (int) MAJOR(deps->device[i]),
> +			       (int) MINOR(deps->device[i]));
> +	}
>  	printf("\n");
>  
>  	if (multiple_devices && _switches[VERBOSE_ARG])
> @@ -1831,8 +1840,16 @@ static int _deps(CMD_ARGS)
>  
>  static int _display_name(CMD_ARGS)
>  {
> -	printf("%s\t(%d, %d)\n", names->name,
> -	       (int) MAJOR(names->dev), (int) MINOR(names->dev));
> +	char dev_name[PATH_MAX];
> +
> +	if (_switches[NAMES_ARG] &&
> +	    dm_device_get_name((uint32_t) MAJOR(names->dev),
> +			       (uint32_t) MINOR(names->dev),
> +			       1,dev_name, PATH_MAX))

+space  1, dev_name

> +		printf("%s\t(%s)\n", names->name, dev_name);
> +	else
> +		printf("%s\t(%d, %d)\n", names->name,
> +		       (int) MAJOR(names->dev), (int) MINOR(names->dev));
>  
>  	return 1;
>  }
> @@ -2057,6 +2074,7 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
>  	const char *name;
>  	const struct dm_info *info;
>  	int first_on_line = 0;
> +	char dev_name[PATH_MAX];
>  
>  	/* Sub-tree for targets has 2 more depth */
>  	if (depth + 2 > MAX_DEPTH)
> @@ -2091,9 +2109,15 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
>  
>  	if (_tree_switches[TR_DEVICE]) {
>  		_out_string(name ? " (" : "(");
> -		(void) _out_int(info->major);
> -		_out_char(':');
> -		(void) _out_int(info->minor);
> +		if (_switches[NAMES_ARG] &&
> +		    dm_device_get_name(info->major, info->minor,
> +				       1, dev_name, PATH_MAX))
> +			_out_string(dev_name);
> +		else {
> +			(void) _out_int(info->major);
> +			_out_char(':');
> +			(void) _out_int(info->minor);
> +		}
>  		_out_char(')');
>  	}
>  
> @@ -2780,9 +2804,9 @@ static struct command _commands[] = {
>  	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
>  	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
>  	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
> -	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
> +	{"ls", "[--names] [--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},

Hmm, here we have somewhat inconsistent interface, where --tree option
supports  uuid -o option, but pure  'ls' does not have a way to display uuid
with device major:minor number.  So maybe  --uuid should be also add as direct
option like --names (agk?)

Zdenek


