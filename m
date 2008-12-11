From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 15:36:53 -0500
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <87y6ypcn7l.fsf@eriador.mornfall.net>
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
Message-ID: <1229027813.20795.15.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2008-12-09 at 17:44 +0100, Petr Rockai wrote:
>  /* FIXME: remove redundant vg_name */
>  int vg_remove_single(struct cmd_context *cmd, const char *vg_name,
> -                    struct volume_group *vg, int consistent,
> +                    struct volume_group *vg,
>                      force_t force __attribute((unused)))
>  {
>         struct physical_volume *pv;
> @@ -340,7 +340,7 @@ int vg_remove_single(struct cmd_context 
>         unsigned lv_count;
>         int ret = 1;
>  
> -       if (!vg || !consistent || vg_missing_pv_count(vg)) {
> +       if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
>                 log_error("Volume group \"%s\" not found, is
> inconsistent "
>                           "or has PVs missing.", vg_name);
>                 log_error("Consider vgreduce --removemissing if
> metadata "

Did you mean to put this in the second patch?


