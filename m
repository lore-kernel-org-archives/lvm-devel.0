From: Milan Broz <mbroz@redhat.com>
Date: Mon, 08 Feb 2010 14:32:52 +0100
Subject: [PATCH] Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <4B700EDC.7020505@redhat.com>
References: <4B700EDC.7020505@redhat.com>
Message-ID: <4B701284.1030606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 02/08/2010 02:17 PM, Peter Rajnoha wrote:
> We should not show error messages about locking initialisation failures when it is expected
> and --ignorelockingfailure option is used (rhbz #561938).

> 
> diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> index 54e5e25..db70433 100644
> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -237,7 +237,8 @@ int init_locking(int type, struct cmd_context *cmd)
>  				 _blocking_supported ? "" : "Non-blocking ");
>  
>  		if (!init_file_locking(&_locking, cmd)) {
> -			log_error("File-based locking initialisation failed.");
> +			if (!ignorelockingfailure())
> +				log_error("File-based locking initialisation failed.");

I do not like this patch at all.

"Ignore locking failure" does not mean "Do not print error when locking failed" IMHO.

I thought that dracut use rw root. So something changed again and remounts it to read-only again?

Milan


