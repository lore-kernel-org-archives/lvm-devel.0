From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 23 Nov 2008 23:06:38 -0500
Subject: [PATCH] (7/11) API improvements
In-Reply-To: <873aie3q69.fsf@eriador.mornfall.net>
References: <873aie3q69.fsf@eriador.mornfall.net>
Message-ID: <1227499598.6608.27.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 19:15 +0100, Petr Rockai wrote:
> +int vg_read_error(vg_t *vg) {
> +       if (!vg)
> +               return FAILED_ALLOCATION;
> +       if (vg->read_failed & EXISTENCE_CHECK)
> +               return vg->read_failed & ~(EXISTENCE_CHECK |
> FAILED_NOTFOUND);
> +       return vg->read_failed;
> +}
> +
> +/* Returns true if the volume group already exists. If unsure, it
> will return
> +   true (it might exist, but we are not sure, as the read failed for
> some
> +   other reason). */
> +
> +int vg_exists(vg_t *vg) {
> +       if (!vg)
> +               return 1;
> +       log_error("vg_exists: %d != %d?", vg->read_failed,
> FAILED_NOTFOUND | EXISTENCE_CHECK);
> +       if (vg->read_failed == (FAILED_NOTFOUND | EXISTENCE_CHECK))
> +               return 0;
> +       return 1;
> +}
> 

Although the comment explains the vg_exists() function may be just a
guess, it is misleading to have a function called "vg_exists()" that
takes a vg_t * and returns true of vg_t * is NULL.

Also from what I can tell, all places that call vg_exists() is preceeded
immediately by a call to vg_read_error() which does the same check.


