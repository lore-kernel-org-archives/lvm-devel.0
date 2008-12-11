From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 15:47:31 -0500
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <87y6ypcn7l.fsf@eriador.mornfall.net>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
Message-ID: <1229028451.20795.22.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2008-12-09 at 17:44 +0100, Petr Rockai wrote:
> -int vg_check_status(const struct volume_group *vg, uint32_t status)
> +static int _vg_check_status(const struct volume_group *vg, uint32_t
> status)
>  {
> +       uint32_t ret = 0;
> 

Can you clean up some of the return value prototypes so they use
uint32_t consistently for return values?  This includes
vg_check_status(), vg_read_error(), vg_exists(), and the flag
definitions.


