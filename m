From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 Jan 2010 14:10:15 +0000
Subject: [PATCH 0/4] Add support for libdevmapper and dmsetup to disable udev checking on request
In-Reply-To: <4B4B1F3B.9090101@redhat.com>
References: <4B4746BF.7090300@redhat.com>
	<20100108180807.GF6042@agk-dp.fab.redhat.com>
	<4B4B1F3B.9090101@redhat.com>
Message-ID: <20100111141014.GA5294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 11, 2010 at 01:53:15PM +0100, Peter Rajnoha wrote:
> On 01/08/2010 07:08 PM, Alasdair G Kergon wrote:
> > Looks OK, but please could we have some suitable messages when this environment
> > option got set?
> 
> You mean some simple log_debug("{DM, LVM} udev checking disabled") when the
> {DM, LVM}_UDEV_DISABLE_CHECKING=1 env var is set?
> 
> (Then I would also need to move it further in the code after logging is properly set...)
 
Well only things that are necessary prerequisites of enabling logging get done
before logging is enabled.  Everything that can be delayed is delayed.

Alasdair


