From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 10 Jul 2012 23:54:59 +0100
Subject: how to determine polling and dmeventd monitoing state?
In-Reply-To: <3619203.GE0e6jSkAE@laptop>
References: <3619203.GE0e6jSkAE@laptop>
Message-ID: <20120710225459.GR30961@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 10, 2012 at 01:55:30PM -0700, ben wrote:
> I know that I can look through the deamon log to see if dmeventd ismonitoring 
> a volume but is there any practical way for a program to query the system to 
> get that information? Is the polling status displayed or accessable anywhere? 
> I certainly can't find it. Thank you.
 
Good point. It's available internally through 
   seg->segtype->ops->target_monitored()
and we need to expose this through lvs.

Alasdair


