From: Petr Rockai <prockai@redhat.com>
Date: Wed, 12 May 2010 17:12:57 +0200
Subject: [PATCH] In dmeventd, bridge LVM error log output to syslog.
In-Reply-To: <874oield63.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 11 May 2010 16:35:00 +0200")
References: <87mxwcq2ue.fsf@twilight.int.mornfall.net.>
	<20100507011850.GR27027@agk-dp.fab.redhat.com>
	<874oield63.fsf@twilight.int.mornfall.net.>
Message-ID: <87iq6tgnly.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
>> I'd prefer to see a patch that adds a middle category, taking some of
>> the DEBUG messages and logging them as ERR or WARN.
>
> I will submit a patch later that changes the commandline options, so we
> can optionally enable the DEBUG logs to syslog with a -d-style option to
> dmeventd. For users, it doesn't make any sense to be logging at the most
> verbose level, to syslog.
Since Alasdair said this can't go in without the commandline options,
there's a patch that does both.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-logging-1.diff
Type: text/x-diff
Size: 4639 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100512/0241ee3f/attachment.bin>
