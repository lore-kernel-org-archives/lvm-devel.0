From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Aug 2007 13:52:21 +0100
Subject: Re: LVM2/lib/metadata lv_manip.c
In-Reply-To: <20070806203548.25477.qmail@sourceware.org>
References: <20070806203548.25477.qmail@sourceware.org>
Message-ID: <20070807125220.GO2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 06, 2007 at 08:35:48PM -0000, wysochanski at sourceware.org wrote:
> 	Add support for renaming mirrored LVs.

A patch missing accompanying discussion and analysis.


Did you test this in a cluster?
That's a pre-requisite before this code forms part of any release.

> +static int _rename_single_lv(struct logical_volume *lv, char *new_name)

Should not be _ there.  (Error repeated throughout patch.)
You only need that when it does not follow an explicit log message.

> +static char * sub_lv_name_suffix(const char *lvname)

Remove space after *.
Add _ prefix (static).

[And I don't quite understand the need for this function, and don't
want to see _mimage etc. hard-coded there.]

> + * Returns 0 on failure, 1 on success.

Superfluous comment - it's the default.

> + * If a new name for the sub LV cannot be determined, 1 is returned.

How can that happen?  Why return success if it does?

> + * 'lv_main_old' and 'lv_main_new' are old and new names of the main LV.

So 'sub_lv' is new terminology you're introducing to describe any LV
that is used by any segment of another 'main' LV ?

Currently we have 'toplevel' and 'visible'.
I don't think we need to add 'main'.
I'll ponder what value comes from introducing 'sub_lv'.

And 'lv' suggests struct logical_volume * - but these are const char *
so just call then lv_name_old and lv_name_new.

> +static int _rename_sub_lv(struct cmd_context *cmd,

> +	size_t l;

Use a more-descriptive name.

> +	/* Rename only if the lv has known suffix */
> +	if (!(suffix = sub_lv_name_suffix(lv->name)))
> +		return 1;
> +	/* Make sure that lv->name is exactly a lv_main_old + suffix */
> +	l = suffix - lv->name;
> +	if (strlen(lv_main_old) != l || strncmp(lv->name, lv_main_old, l))
> +		return 1;

The logic here seems a bit twisted.  In what circumstances would those
tests fail and why treat this as success?  And if you are going to
validate the names, then do it properly e.g. why proceed if you find a
mirror log with a suffix 'mimage'?

Today, they should never fail unless there's been a coding bug (or
someone's edited the metadata making it invalid).  Any checks
should be in vg_validate.  It's inconsistent to, in one place, assume
'mimage' was put there by the tools (there's no check on what follows
'mimage') and is a valid name, yet in another place if an invalid name
is encountered, return success.

These are internal LVs with naming under the complete control of LVM2.
If the names became wrong somehow, then issue a log_error by all means but
then correct the names!

Or maybe this is to support future enhancements?  But we haven't yet
discussed how to name internal LVs when they are stacked.

One simple way out perhaps?
  Check if it begins with lv_name_old: if so, replace that part of the
  string with lv_name_new;  if not, log_error and make the entire rename
  fail.  (Add complete name validation to vg_validate, if you wish.)

> +		log_error("Cannot rename hidden LV \"%s\".", lv->name);

New terminology again - please resist and discuss first!
('Internal LV' has been used already.  We might be able to improve on
that, but we should try to avoid using different terminology in different
places.)

> +	/* rename sub LVs */
> +	names[0] = lv->name;
> +	names[1] = new_name;

How do I work out what '0' and '1' mean there?  Please avoid hiding
things like that.  Use a struct there (or enum).

Alasdair
-- 
agk at redhat.com


