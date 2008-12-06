From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 6 Dec 2008 17:04:40 +0000
Subject: [PATCH 1/2] Add generic function to read /dev/urandom, used in uuid calculation.
In-Reply-To: <1228579966-27083-1-git-send-email-dwysocha@redhat.com>
References: <1228579966-27083-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081206170440.GH26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Dec 06, 2008 at 11:12:45AM -0500, Dave Wysochanski wrote:
> --- a/lib/Makefile.in
> +++ b/lib/Makefile.in
> @@ -80,6 +80,7 @@ SOURCES =\
>  	misc/lvm-globals.c \
>  	misc/lvm-string.c \
>  	misc/lvm-wrappers.c \
> +	misc/random.c \
>  	misc/timestamp.c \
>  	misc/util.c \

For the newer files I've been using an lvm- prefix.
But rather than adding a new file, just add it to either lvm-file.c
(it's doing file manipulation) or lvm-wrappers.c (it's wrapping
a random number generating function).

> +	if ((fd = open("/dev/urandom", O_RDONLY)) < 0) {
> +		log_sys_error("open", "get_random: /dev/urandom");
> +		return 0;
> +	}

(strictly we should stat it first and have a fallback if it doesn't exist - 
a FIXME to suggest that?  Not worth coding though till someone actually needs it.)

> +	if (read(fd, buf, len) != (ssize_t) len) {
> +		log_sys_error("read", "get_random: /dev/urandom");
> +		if (close(fd))
> +			stack;
> +		return 0;
> +	}

Again, a FIXME to handle the standard complexity of read()?
(Ideally we'd push this through the existing _io() function instead of having
another less-well-implemented open...read...close sequence.)

Alasdair
-- 
agk at redhat.com


