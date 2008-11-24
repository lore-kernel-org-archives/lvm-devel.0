From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 23 Nov 2008 22:55:17 -0500
Subject: [PATCH] (11/11) re-instantiate automatic VG recovery
In-Reply-To: <87fxme2amo.fsf@eriador.mornfall.net>
References: <87fxme2amo.fsf@eriador.mornfall.net>
Message-ID: <1227498917.6608.14.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 19:36 +0100, Petr Rockai wrote:
> +static vg_t *_recover_vg(struct cmd_context *cmd, const char *lock,
> const char *vg_name,
> +                        const char *vgid, uint32_t lock_flags )
> +{
> +       int consistent = 1;
> +       struct volume_group *vg;
> +
> +       lock_flags &= ~LCK_TYPE_MASK;
> +       lock_flags |= LCK_WRITE;
> +
> +       unlock_vg(cmd, lock);
> +       if (!lock_vol(cmd, lock, lock_flags))
> +               return_NULL;
> +
> +       if (!(vg = vg_read_internal(cmd, vg_name, vgid, &consistent)))
> +               return_NULL;
> +       if (!consistent)
> +               return_NULL;
> +       return vg;
> +}
> +
>  /*

A couple things:
1) Is there a reason you dropped the "if (lockingfailed()) return NULL"
from your version?  The original recover_vg() in toollib had this:
struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
				uint32_t lock_type)
{
	int consistent = 1;

	/* Don't attempt automatic recovery without proper locking */
	if (lockingfailed())
		return NULL;

	lock_type &= ~LCK_TYPE_MASK;
	lock_type |= LCK_WRITE;

2) Note that in some of the original paths (e.g. vgconvert) that called
recover_vg(), there was a call to "dev_close_all()", while others did
not (e.g. process_each_lv()).

3) Previous to this, in the case of inconsistent metadata, we sometimes
would do recovery while others we would not.  Now we're doing recovery
in all cases?  Is this what we want, especially with the reporting
tools?




