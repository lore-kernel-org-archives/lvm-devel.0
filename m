From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 6 Mar 2011 01:51:18 +0000
Subject: LVM2/libdm/ioctl libdm-iface.c
In-Reply-To: <4D72E53A.6070104@redhat.com>
References: <20110305211719.11626.qmail@sourceware.org>
	<20110306011808.GW10767@agk-dp.fab.redhat.com>
	<4D72E53A.6070104@redhat.com>
Message-ID: <20110306015118.GY10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Mar 06, 2011 at 02:36:58AM +0100, Milan Broz wrote:
> IMHO that message should not be there at all. If application relies on
> it, then it must fail completely, warning is not enough.
 
Indeed - that should be the long-term change - to fail instead of warn,
and let the application decide whether to retry less-securely.

Alasdair


