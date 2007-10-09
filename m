From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 9 Oct 2007 03:00:40 +0100
Subject: Allow $DM_DEVDIR envvar to override default of "/dev".
In-Reply-To: <87przp1psr.fsf@rho.meyering.net>
References: <87przp1psr.fsf@rho.meyering.net>
Message-ID: <20071009020040.GR10006@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 08, 2007 at 07:25:56PM +0200, Jim Meyering wrote:
> any existing LVM set-up, I've been using LVM_SYSTEM_DIR to specify

> Here's a patch to make dmsetup honor a new DM_DEVDIR envvar,

Small point, but should that be DM_DEV_DIR for consistency with
LVM_SYSTEM_DIR ?

> +	} else {
> +		dev_dir = "/dev";

Can you make that a #define at the top of the file?
(Try to keep hard-coded values easy to spot.)

> +	if (*dev_dir != '/')
> +		return 0;

log_error ?
(Functions should produce an error message as close as possible to the
place the problem is detected; all functions that return failure must
log a message before returning - using a macro like 'stack' if you don't
want the user to see it.  The only exceptions (very rare) are functions
expected to fail frequently that would produce too many log messages.)

> +	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
> +	    >= sizeof _dm_dir)
> +		return 0;

and here

Also consider dm_snprintf rather than snprintf.
[lvm2 uses this, but bits of dm haven't been converted]

Alasdair
-- 
agk at redhat.com


