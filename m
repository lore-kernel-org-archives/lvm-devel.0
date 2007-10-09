From: Jim Meyering <jim@meyering.net>
Date: Tue, 09 Oct 2007 14:04:16 +0200
Subject: [dm-devel] Re: [lvm-devel] Allow $DM_DEVDIR envvar to override
	default of "/dev".
In-Reply-To: <87r6k4y03r.fsf@rho.meyering.net> (Jim Meyering's message of
	"Tue, 09 Oct 2007 13:54:32 +0200")
References: <87przp1psr.fsf@rho.meyering.net>
	<20071009020040.GR10006@agk.fab.redhat.com>
	<87r6k4y03r.fsf@rho.meyering.net>
Message-ID: <87lkacxznj.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:
> BTW, here's a proposed update for the man page:
>
> diff --git a/man/dmsetup.8 b/man/dmsetup.8
> index 5b2ed9f..74a5f1b 100644
> --- a/man/dmsetup.8
> +++ b/man/dmsetup.8
> @@ -341,6 +341,11 @@ for creating devices with holes in them.
>  .br
>  2056320 2875602 linear /dev/hdb 1028160
>
> +.SH FILES
> +These commands normally operate on files in \fB/dev\fP.
> +However, if you set the DM_DEV_DIR environment variable to some
> +other absolute directory name, they will use it instead.

I'm redoing it like LVM_SYSTEM_DIR in lvm.8.


