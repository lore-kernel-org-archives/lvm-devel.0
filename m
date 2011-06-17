From: Milan Broz <mbroz@redhat.com>
Date: Fri, 17 Jun 2011 15:59:32 +0200
Subject: [PATCH] lvm2: add configuration option to enable udev fallback code only when needed
In-Reply-To: <4DFB4B09.9080902@redhat.com>
References: <4DFB4B09.9080902@redhat.com>
Message-ID: <4DFB5DC4.3070908@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/17/2011 02:39 PM, Peter Rajnoha wrote:
> We've used udev fallback code till now to check whether udev
> created/removed the entries in /dev correctly and if not,
> a repair was done (giving a warning messagea about that).
> 
> This patch adds a possibility to enable this additional check
> and subsequent fallback only when required (debugging purposes
> mostly) and trust udev completely.
> 
> So let's disable the fallback code by default and add a new
> configuration option "activation/udev_fallback".

ack.

(also systemd people should be happy, because fallback hides
problems in dependencies.)

> @@ -36,6 +36,7 @@ struct config_info {
>  	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
>  	int udev_rules;
>  	int udev_sync;
> +	int udev_fallback;

nitpicking - isn't it wasting of space? udev_fallback:1 ? ;-)
(probably some patch later if it is worth to do that)

Milan


