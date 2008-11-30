From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 30 Nov 2008 19:40:37 +0000
Subject: [PATCH] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <1228072273-8119-1-git-send-email-dwysocha@redhat.com>
References: <1228055977.3315.21.camel@localhost.localdomain>
	<1228072273-8119-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081130194037.GK13235@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Nov 30, 2008 at 02:11:13PM -0500, Dave Wysochanski wrote:
> +int pvcreate_devices(struct cmd_context *cmd, int pv_count, char **pv_names)

Can that hook instead into vg_extend() to replace the error message?
Current explicit PV functionality needs to become handled implicitly
throughout the code, rather than "do all the PV things" then "do all the
VG things".

Currently:
  vgcreate = { create empty vg; vgextend; }

int vg_extend(struct volume_group *vg, int pv_count, char **pv_names)
{
...
        /* attach each pv */
        for (i = 0; i < pv_count; i++) {
                if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_names[i]))) {
                        log_error("%s not identified as an existing "
                                  "physical volume", pv_names[i]);
                        goto bad;
                }
                
Alasdair
-- 
agk at redhat.com


