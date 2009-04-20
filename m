From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 20 Apr 2009 12:15:36 +0200
Subject: [PATCH] Udev integration: udev rules 2/3
In-Reply-To: <20090415181253.GK7843@agk.fab.redhat.com>
References: <49DC9A17.9010705@redhat.com>
	<20090415181253.GK7843@agk.fab.redhat.com>
Message-ID: <49EC4B48.2050606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/2009 08:12 PM, Alasdair G Kergon wrote:
> On Wed, Apr 08, 2009 at 02:35:35PM +0200, Peter Rajnoha wrote:
>> ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
> 
> Seems to be some repetition here.  Does udev support including files inline
> within other files?

This just reminds me one thing -- we don't have to assign DM_UUID and DM_NAME
vars in the rules following the basic DM udev rules. Once it's assigned,
it's set in the other rules as well, so we can save a little with this,
no need to read it again.

Peter


