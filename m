From: Petr Rockai <prockai@redhat.com>
Date: Tue, 11 May 2010 16:35:00 +0200
Subject: [PATCH] In dmeventd, bridge LVM error log output to syslog.
In-Reply-To: <20100507011850.GR27027@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Fri, 7 May 2010 02:18:50 +0100")
References: <87mxwcq2ue.fsf@twilight.int.mornfall.net.>
	<20100507011850.GR27027@agk-dp.fab.redhat.com>
Message-ID: <874oield63.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> On Thu, May 06, 2010 at 08:53:13PM +0200, Peter Rockai wrote:
>> as discussed, this is the first part of dmeventd logging. I am not
>> touching any options related to debugging, that will come as a separate
>> patch later. This patch provides the necessary minimum for any useful
>> diagnostics of dmeventd/lvconvert --repair issues.
>
> Sorry, but I don't understand this yet.
> What changes are you intending to make to the log messages?
>
> Previously *all* messages got logged, but only as either CRIT or as DEBUG,
> so the sysadmin had a choice of seeing all messages (including trival ones)
> or only the most critical messages.

Now this is interesting...

> The new patch appears to drop some messages instead of logging them!

!

There used to be this:
-               lvm2_log_level(_lvm_handle, LVM2_LOG_SUPPRESS);
-               /* FIXME Temporary: move to dmeventd core */

but that disappeared with this patch:

    Thu Jan 21 23:15:46 CET 2010  agk
      Add libdevmapper-event-lvm2.so to serialise dmeventd plugin liblvm2cmd use.

so it seems that versions of dmeventd since this patch spam syslog with
everything, unconditionally. I wasn't aware of this behaviour
change. Either way, I think what we have now is wrong -- a couple of
dmeventd events produced something like 2 megabytes of logs.

What we had *originally* (before end of January) was to log nothing, now
we log everything as DEBUG. This patch logs things at their right
priority and suppresses -vvvv-style output to syslog, which I think is a
good thing (this will likely bog down some syslog implementations).

> I'd prefer to see a patch that adds a middle category, taking some of
> the DEBUG messages and logging them as ERR or WARN.

I will submit a patch later that changes the commandline options, so we
can optionally enable the DEBUG logs to syslog with a -d-style option to
dmeventd. For users, it doesn't make any sense to be logging at the most
verbose level, to syslog.

Yours,
   Petr.


