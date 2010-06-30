From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 14:37:25 +0200
Subject: [PATCH] Fix vgremove to allow removal of VG with missing PVs.
In-Reply-To: <1277897478-15448-1-git-send-email-mbroz@redhat.com> (Milan
	Broz's message of "Wed, 30 Jun 2010 13:31:18 +0200")
References: <1277897478-15448-1-git-send-email-mbroz@redhat.com>
Message-ID: <87mxuclmre.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Milan Broz <mbroz@redhat.com> writes:
> diff --git a/WHATS_NEW b/WHATS_NEW
> index 0c415a3..b485a59 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>  Version 2.02.69 - 
>  ================================
> +  Fix vgremove to allow removal of VG with missing PVs. (2.02.52)
>    Add {pv|vg}_mda_used_count which displays a count of mdas w/ignored bit clear.
>    Add vg_mda_copies which displays the value of --vgmetadatacopies.
>    Describe --vgmetadatacopies in lvm.conf and other man pages.
> diff --git a/test/t-activate-partial.sh b/test/t-activate-partial.sh
> index f0a95c5..15f5965 100644
> --- a/test/t-activate-partial.sh
> +++ b/test/t-activate-partial.sh
> @@ -15,3 +15,6 @@ lvchange -v --refresh --partial $vg/mirror
>  # also check that vgchange works
>  vgchange -a n --partial $vg
>  vgchange -a y --partial $vg
> +
> +# check vgremove
> +vgremove -f $vg
> \ No newline at end of file
> diff --git a/tools/vgremove.c b/tools/vgremove.c
> index b719ca2..56e18ef 100644
> --- a/tools/vgremove.c
> +++ b/tools/vgremove.c
> @@ -49,7 +49,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
>  		}
>  	}
>  
> -	if (!vg_remove_check(vg)) {
> +	if (!force && !vg_remove_check(vg)) {
>  		stack;
>  		return ECMD_FAILED;
>  	}

Looks OK as far as I can tell. Maybe just add "not vgremove $vg" just
before "vgremove -f $vg" in the test.

Yours,
    Petr.


