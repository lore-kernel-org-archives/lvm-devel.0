From: Petr Rockai <prockai@redhat.com>
Date: Fri, 05 Jun 2009 19:41:08 +0200
Subject: [PATCH] Do not fork daemon when dmeventd cannot be found.
In-Reply-To: <4A291FE1.6010006@redhat.com> (Milan Broz's message of "Fri, 05
	Jun 2009 15:38:41 +0200")
References: <4A291FE1.6010006@redhat.com>
Message-ID: <87bpp2tw7f.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

Milan Broz <mbroz@redhat.com> writes:
> diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
> index 2650cf0..dae76d3 100644
> --- a/daemons/dmeventd/libdevmapper-event.c
> +++ b/daemons/dmeventd/libdevmapper-event.c
> @@ -425,6 +425,12 @@ static int _start_daemon(struct dm_event_fifos *fifos)
>  
>        start_server:
>  	/* server is not running */
> +
> +	if (stat(DMEVENTD_PATH, &statbuf)) {
> +		log_error("Unable to find dmeventd.");
> +		return_0;
> +	}
Although not exactly spectacular, I guess this is fine. Just one thing, there's
an execvp later for DMEVENTD_PATH, so this may actually not be really a safe
check (DMEVENTD_PATH -> "dmeventd" should work without this check, but will
break with it).

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


