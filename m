From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 01 Dec 2008 09:19:57 -0500
Subject: [PATCH] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <20081130194037.GK13235@agk.fab.redhat.com>
References: <1228055977.3315.21.camel@localhost.localdomain>
	<1228072273-8119-1-git-send-email-dwysocha@redhat.com>
	<20081130194037.GK13235@agk.fab.redhat.com>
Message-ID: <1228141197.3256.4.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Sun, 2008-11-30 at 19:40 +0000, Alasdair G Kergon wrote:
> On Sun, Nov 30, 2008 at 02:11:13PM -0500, Dave Wysochanski wrote:
> > +int pvcreate_devices(struct cmd_context *cmd, int pv_count, char **pv_names)
> 
> Can that hook instead into vg_extend() to replace the error message?
> Current explicit PV functionality needs to become handled implicitly
> throughout the code, rather than "do all the PV things" then "do all the
> VG things".
> 
> Currently:
>   vgcreate = { create empty vg; vgextend; }
> 
> int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
> {
> ...
>         /* attach each pv */
>         for (i = 0; i < pv_count; i++) {
>                 if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
>                         log_error("%s not identified as an existing "
>                                   "physical volume", pv_names[i]);
>                         goto bad;
>                 }
>                 

I tried that in my first patch and ran into an issue with VG_ORPHAN
lock.  
http://www.redhat.com/archives/lvm-devel/2008-November/msg00075.html

vgextend() obtains VG_ORPHAN, then the lock on the vg before calling
vg_extend().  So if I put pvcreate_devices() logic in there, that calls
down into pvcreate_single(), which also tries to obtain / release
VG_ORPHAN.  I could put logic into pvcreate_single() to check to see if
lock is already obtained (original patch has that) and not try to
reaquire / release VG_ORPHAN (original patch missed release part), but
that looked more hacky than the solution of first calling the logic at
the higher level in the tool.  Would you prefer this first approach and
detecting whether VG_ORPHAN was obtained?


