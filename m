From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 11 Jul 2012 09:09:53 +0200
Subject: how to determine polling and dmeventd monitoing state?
In-Reply-To: <20120710225459.GR30961@agk-dp.fab.redhat.com>
References: <3619203.GE0e6jSkAE@laptop>
	<20120710225459.GR30961@agk-dp.fab.redhat.com>
Message-ID: <4FFD26C1.2080200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/11/2012 12:54 AM, Alasdair G Kergon wrote:
> On Tue, Jul 10, 2012 at 01:55:30PM -0700, ben wrote:
>> I know that I can look through the deamon log to see if dmeventd ismonitoring 
>> a volume but is there any practical way for a program to query the system to 
>> get that information? Is the polling status displayed or accessable anywhere? 
>> I certainly can't find it. Thank you.
>  
> Good point. It's available internally through 
>    seg->segtype->ops->target_monitored()
> and we need to expose this through lvs.

In addition to that, we could also revive the 'dmevent_tool'
that is a part of the dmraid at the moment and include this one in
lvm2 upstream (probably as a part of dmsetup or dmeventd or a separate
tool even). Existing tool from dmraid upstream is supposed to show dm
devices in general and their status with respect to dmeventd monitoring.
Though the tool itself needs a bit of a cleanup before porting.

There's also a bugzilla report open for this functionality:
  https://bugzilla.redhat.com/show_bug.cgi?id=805425

Peter


