From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 6 Aug 2007 14:35:13 +0100
Subject: Re: LVM2 ./WHATS_NEW man/lvconvert.8 man/lvcreate. ...
In-Reply-To: <20070801210107.14976.qmail@sourceware.org>
References: <20070801210107.14976.qmail@sourceware.org>
Message-ID: <20070806133513.GG2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 01, 2007 at 09:01:07PM -0000, jbrassow at sourceware.org wrote:
> 	# Creating a 2-way mirror
> 	$> lvcreate -m1 ... # implicitly use default disk logging
> 	$> lvcreate -m1 --log disk ... # explicit disk logging
> 	$> lvcreate -m1 --log core ... # specify core logging
> 	$> lvcreate -m1 --corelog ... # old way still works
 	
I don't see code to cope with '--corelog --log disk'.
Simplest just to disallow both options at once?

> +++ LVM2/WHATS_NEW	2007/08/01 21:01:06	1.676
> +  Add --log argument to specify log type for mirrors.

Slightly more detail called for: lvconvert & lvcreate.

> +++ LVM2/man/lvconvert.8	2007/08/01 21:01:06	1.6
> -\-m/\-\-mirrors Mirrors [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]

--corelog still needs to be there!

>  .TP
> -.I \-\-corelog
> -This optional argument tells lvconvert to switch the
> -mirror from using a disk-based (persistent) log to
> -an in-memory log.  You may only specify this option
> -when the \-\-mirror argument is the same degree of
> -the mirror you are changing.

Ditto. Move below, then say it's same as --log core.

> +.I \-\-log disk/core
> +This optional argument gives the ability to switch the

"...argument switches..."

> +logging type that is used by a mirror.  The logging type

"that is used by" - rephrase - "of"?

"switches from...to..."  else "changes to"

> +can be either "disk" (persistent) or "core" (non-persistent).


> +a two-legged mirror logical volume.

Do we use 'legs' anywhere?  Is our teminology inconsistent?

> +++ LVM2/man/lvcreate.8	2007/08/01 21:01:06	1.15

Similar comments.

> -Specifying the optional argument "--corelog" will create a mirror with
> -an in-memory log verses a disk-based (persistent) log.  While this
> -removes the need for an extra log device and *may* be slightly faster,
> -it requires that the entire mirror be resynchronized upon each
> -instantiation (e.g. a reboot).
> +The optional argument "--log" gives the ability to specify the type
> +of mirror log to be used.  The available types are "disk" and "core",
> +where "disk" is the default.  The "disk" log is persistent and requires
> +a small amount of storage space - usually on a separate device from the
> +mirror legs.  While the "disk" log may cause the mirror to be slightly
> +slower during writes, it prevents the need to completely resynchronize
> +the mirror upon each instantiation (e.g. a reboot).

Please try to improve this so the emphasis remains on encouraging the default
behaviour (disk).  Also, please remove the quotes around "disk".  We don't use
them elsewhere.  And use .I for arguments like --log.

> +++ LVM2/tools/commands.h	2007/08/01 21:01:06	1.98
> -   "[-m|--mirrors Mirrors [--corelog]]\n"
> +   "[-m|--mirrors Mirrors [--log {disk|core}]]\n"

And again: --corelog must remain for compatibility reasons!
We can't just pretend it never existed.  What if someone finds it in
an existing script and looks at the help/man page and it's not there?

> +++ LVM2/tools/lvconvert.c	2007/08/01 21:01:06	1.31

> +	int count;

Please use a more-specific variable name.

> +	if (arg_count(cmd, log_ARG) > 1) {
> +		log_error("Too many --log arguments supplied.");
> +		return 0;
> +	}

If we're going to test for multiple arguments, please do this generically,
not in every tool independently!  This section needs to come out.

> +	if (arg_count(cmd, log_ARG) || arg_count(cmd, mirrors_ARG))
> +		count = 1;
> +	count += arg_count(cmd, snapshot_ARG);
> +	if (count != 1) {
> +		log_error("--snapshots argument cannot be mixed "
> +			  "with --mirrors or --log");

Drop 'count' and do this all in one go?
  if (snapshots and (mirrors or log))

> @@ -237,6 +254,8 @@
> +	int corelog = 0;

Firstly, you're using this unsigned;  but secondly it's really an enum.

> @@ -267,6 +286,31 @@
> +	/*
> +	 * Adjust log type
> +	 */
> +	if (arg_count(cmd, corelog_ARG)) {
> +		log_verbose("Setting logging type to \"core\"");
> +		corelog = 1;
> +	}
> +
> +	if (arg_count(cmd, log_ARG)) {
> +		log_arg = arg_str_value(cmd, log_ARG, "disk");
> +		if (!strcmp("disk", log_arg)) {
> +			log_verbose("Setting logging type to \"disk\"");
> +			corelog = 0;
> +		} else if (!strcmp("core", log_arg)) {
> +			log_verbose("Setting logging type to \"core\"");
> +			corelog = 1;
> +		} else {
> +			log_error("Unknown logging type, \"%s\"", log_arg);
> +			return 0;
> +		}
> +	}

Just one "Setting logging type to %s." please.
Prevent incompatible --log and --corelog together.
And use the enum, perhaps, to record the log type.

> --- LVM2/tools/lvcreate.c	2007/07/17 16:13:12	1.138
> +++ LVM2/tools/lvcreate.c	2007/08/01 21:01:06	1.139

Similar comments.

Alasdair
-- 
agk at redhat.com


