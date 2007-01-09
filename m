From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 9 Jan 2007 20:48:24 +0000
Subject: Why print_log() is doing the memlock check?
In-Reply-To: <20061226150637hoshino-s@mail.jp.nec.com>
References: <20061217115801.GB4982@agk.surrey.redhat.com>
	<20061226150637hoshino-s@mail.jp.nec.com>
Message-ID: <20070109204824.GZ21980@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 26, 2006 at 03:06:37PM +0900, Shinn'ya Hoshino wrote:
> However, when a trouble occurs in the server currently used 
> for business, it needs to avoid that it becomes impossible to 
> investigate in order that there may be no log.
 
We don't have a safe way of logging yet.

What happens, is people temporarily turn on logging during
activation in the config file while debugging, and put things
back again afterwards.
 
A long time ago I started attempting to write some such code but never
finished it.  Look for init_log_direct().
Another approach might be to cache the log messages in memory
then write them out when exiting the critical section.

Alasdair
-- 
agk at redhat.com


