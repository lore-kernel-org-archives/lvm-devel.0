From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 21 Mar 2011 01:47:35 +0000
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <4D8692EF.1030400@redhat.com>
References: <20110320020053.24940.qmail@sourceware.org>
	<4D85FC79.6050709@redhat.com>
	<20110320214149.GZ11163@agk-dp.fab.redhat.com>
	<4D8692EF.1030400@redhat.com>
Message-ID: <20110321014735.GE11163@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> The order would be opposite - and I believe that giving the user knowledge,
> that lvm lacks some part of code to handle this situation and code needs to be
> recompiled with such support is IMHO good hint for error like this.
 
_dm_compat is deprecated functionality and I think the proposed message is
very misleading, and most likely nothing to do with the actual problem
the user needs to address on that code path.

> And also it's worth to know - we have 2 other log_error() already there:

which both look fine (on the deprecated code path).

> > Support was not compiled in so we shouldn't mention anything about it to the
> > user.
> Well that's where I think 'root' should know why the operation failed.
 
No - if the support was not compiled in it is because it is known not to be
required.

Alasdair


