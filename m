From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 May 2010 02:18:50 +0100
Subject: [PATCH] In dmeventd, bridge LVM error log output to syslog.
In-Reply-To: <87mxwcq2ue.fsf@twilight.int.mornfall.net.>
References: <87mxwcq2ue.fsf@twilight.int.mornfall.net.>
Message-ID: <20100507011850.GR27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 06, 2010 at 08:53:13PM +0200, Peter Rockai wrote:
> as discussed, this is the first part of dmeventd logging. I am not
> touching any options related to debugging, that will come as a separate
> patch later. This patch provides the necessary minimum for any useful
> diagnostics of dmeventd/lvconvert --repair issues.
 
Sorry, but I don't understand this yet.
What changes are you intending to make to the log messages?

Previously *all* messages got logged, but only as either CRIT or as DEBUG,
so the sysadmin had a choice of seeing all messages (including trival ones)
or only the most critical messages.

The new patch appears to drop some messages instead of logging them!

I'd prefer to see a patch that adds a middle category, taking some of
the DEBUG messages and logging them as ERR or WARN.

Alasdair


