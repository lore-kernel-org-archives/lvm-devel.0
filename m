From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 24 Apr 2009 11:09:23 +0200
Subject: [PATCH 3/5] Udev integration: add cookie support for dmsetup
In-Reply-To: <49F06807.7010607@redhat.com>
References: <49F06807.7010607@redhat.com>
Message-ID: <49F181C3.30903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> +	if (!dm_notification_sem_inc(cookie) ||
> +			!dm_task_set_cookie(dmt, cookie) ||
> +			!dm_task_run(dmt)) {
> +		dm_notification_sem_close(cookie);
>  		goto out;
> +	}

...yes, still the indents. Hard time getting used to 8 spaces/tab,
I've been using less for years :)

Peter


