From: Petr Rockai <prockai@redhat.com>
Date: Fri, 02 Sep 2011 14:50:13 +0200
Subject: [PATCH] Avoid recursive calls from dmeventd to itself
In-Reply-To: <20110901194235.GA4025@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Thu, 1 Sep 2011 20:42:35 +0100")
References: <8739gh3w98.fsf@aldalome.int.mornfall.net.>
	<20110901194235.GA4025@agk-dp.fab.redhat.com>
Message-ID: <87ippb2jne.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:

> On Thu, Sep 01, 2011 at 03:08:03AM +0200, Peter Rockai wrote:
>> -		lvm2_run(_lvm_handle, "_memlock_dec");
>> +		lvm2_run(_lvm_handle, "_dmeventd_leave");
>
> I'm not keen on overloading it like that.
>
> If it's being used with cmdlib and lvm2_run, use of existing cmdline parameters
> ought to be sufficient to achieve this.

While that is true, I doubt it is a good idea. If we say that dmeventd
is not supposed to call itself recursively (which I believe is the
correct approach), we should enforce that globally. Asking every call
site to take care of this individually is error prone and bound to
introduce the bug sooner or later (especially with the rampant
copy-and-paste programming found in LVM :\).

> It might be a little more code, but I'd rather see it a property of the handle
> never to perform dmeventd monitoring calls.  We never fixed handle init to 
> take multiple settings, so maybe call
>   void lvm2_disable_dmeventd_monitoring(void *handle)
> after handle initialisation to set DMEVENTD_MONITOR_DISABLED and have that take
> precedence over any later attempt to enable monitoring.

This sounds like a better option. Now that raises the question why we
aren't doing the same thing for memlock_{inc,dec}? We should certainly
unify these two things. I'll have a look, and unless I run into a
stumbling block will submit a patch to do that.

(Of course, it would be much better if we could instead move dmeventd
plugins over to using liblvm2api (replacing liblvm2cmd), but I suspect
there's a lot of stuff to resolve before we can hit that mark.)

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


