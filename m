From: Milan Broz <mbroz@redhat.com>
Date: Thu, 21 Jan 2010 14:34:46 +0100
Subject: [PATCH] dmeventd coredump fix
In-Reply-To: <4B5065D4.10108@redhat.com>
References: <4B4EDBDF.7070509@redhat.com> <4B5065D4.10108@redhat.com>
Message-ID: <4B5857F6.7070505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/15/2010 01:55 PM, Zdenek Kabelac wrote:
> So here comes simpler version which only clears structure elements right after
> they are being released:
> 
> --- tools/lvmcmdline.c	11 Jan 2010 19:19:17 -0000	1.111
> +++ tools/lvmcmdline.c	15 Jan 2010 12:51:58 -0000
> @@ -1213,6 +1213,10 @@ static void _fin_commands(void)
>  		dm_free(_cmdline.commands[i].valid_args);
> 
>  	dm_free(_cmdline.commands);
> +
> +	_cmdline.commands = NULL;
> +	_cmdline.num_commands = 0;
> +	_cmdline.commands_size = 0;

ack.

Milan


