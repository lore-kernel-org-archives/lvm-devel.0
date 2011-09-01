From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 1 Sep 2011 20:42:35 +0100
Subject: [PATCH] Avoid recursive calls from dmeventd to itself
In-Reply-To: <8739gh3w98.fsf@aldalome.int.mornfall.net.>
References: <8739gh3w98.fsf@aldalome.int.mornfall.net.>
Message-ID: <20110901194235.GA4025@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Sep 01, 2011 at 03:08:03AM +0200, Peter Rockai wrote:
> -		lvm2_run(_lvm_handle, "_memlock_dec");
> +		lvm2_run(_lvm_handle, "_dmeventd_leave");

I'm not keen on overloading it like that.

If it's being used with cmdlib and lvm2_run, use of existing cmdline parameters
ought to be sufficient to achieve this.

It might be a little more code, but I'd rather see it a property of the handle
never to perform dmeventd monitoring calls.  We never fixed handle init to 
take multiple settings, so maybe call
  void lvm2_disable_dmeventd_monitoring(void *handle)
after handle initialisation to set DMEVENTD_MONITOR_DISABLED and have that take
precedence over any later attempt to enable monitoring.

Alasdair


