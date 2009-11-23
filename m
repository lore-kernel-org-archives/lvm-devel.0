From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 23 Nov 2009 17:00:55 -0500
Subject: [PATCH] Improve mirror DSO's failure logging
In-Reply-To: <c107c082a3a5ab4f4a95.1258760198@localhost>
References: <c107c082a3a5ab4f4a95.1258760198@localhost>
Message-ID: <4B0B0617.9010001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/20/09 18:36, Malahal Naineni wrote:
> The mirror target has the following device states. The mirror DSO
> (daemons/dmeventd/plugins/mirror/dmeventd_mirror.c) doesn't know any of these
> states. This patchs adds these states to the DSO for better error reporting.
> 
> 	A => Alive - No failures
> 	D => Dead - A write failure occurred leaving mirror out-of-sync
> 	S => Sync - A sychronization failure occurred, mirror out-of-sync
> 	R => Read - A read failure occurred, mirror data unaffected

I think that the idea to improve an error reporting is very good.

>  static int _get_mirror_event(char *params)
>  {
> -	int i, r = ME_INSYNC;
> +	int i, r;
>  	char **args = NULL;
>  	char *dev_status_str;
>  	char *log_status_str;
> @@ -89,22 +93,40 @@ static int _get_mirror_event(char *param
>  	sync_str = args[num_devs];
>  
>  	/* Check for bad mirror devices */
> -	for (i = 0; i < num_devs; i++)
> -		if (dev_status_str[i] == 'D') {
> +	r = -1;
> +	for (i = 0; i < num_devs && r == -1; i++) {
> +		switch (dev_status_str[i]) {
> +		case 'D':
>  			syslog(LOG_ERR, "Mirror device, %s, has failed.\n", args[i]);
> -			r = ME_FAILURE;
> +			if (i == 0)
> +				r = ME_PRIMARY_WRITE_FAILURE;
> +			else 
> +				r = ME_SECONDARY_WRITE_FAILURE;
> +			break;
> +		case 'S':
> +			syslog(LOG_ERR, "Mirror synchronization failed. "
> +					"device, %s, failed.\n", args[i]);
> +			r = ME_SYNC_FAILURE;
> +			break;
> +		case 'R':
> +			syslog(LOG_ERR, "Mirror device, %s, read failed.\n",
> +					args[i]);
> +			r = ME_READ_FAILURE;
> +			break;
>  		}
> +	}

I'm afraid that only an error status of the device with the smallest index
of the dev_status_str[] array will be reported. For example, if the status
is "ARD," "r" will have a value, ME_READ_FAILURE. Then, a write failure
event (ME_PRIMARY_WRITE_FAILURE and ME_SECONDARY_WRITE_FAILURE) won't be
detected in process_event(). I think that "WRITE_FAILURE" events should
have priority.

Thanks,
Taka


