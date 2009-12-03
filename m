From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 3 Dec 2009 00:58:40 +0000
Subject: [PATCH] Disable udev rules on change event with DISK_RO=1
In-Reply-To: <4B152425.4090506@redhat.com>
References: <4B152425.4090506@redhat.com>
Message-ID: <20091203005839.GP22702@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 01, 2009 at 03:11:49PM +0100, Peter Rajnoha wrote:
> We need to detect this and disable the rule application so the
> meaning of this change event is not interchanged with the regular
> change event used while resuming/renaming DM devices.
 
Ack.

multipathd may wish to react to this.

Alasdair


