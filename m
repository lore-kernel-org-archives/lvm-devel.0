From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 8 Apr 2010 00:00:39 +0100
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
In-Reply-To: <87iq826gj3.fsf@twilight.int.mornfall.net.>
References: <20100407200443.26841.qmail@sourceware.org>
	<87iq826gj3.fsf@twilight.int.mornfall.net.>
Message-ID: <20100407230038.GG511@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 08, 2010 at 12:31:44AM +0200, Peter Rockai wrote:
> As far as I can tell, this r = 0 is new behaviour that breaks a number
> of tests and may break user scripts. Is it necessary?
 
Well the tests weren't working for other reasons, but I want to see what
fails and why before deciding what to do about it.

The code was inconsistent - if the device being deleted is opened before
this if statement, the function would return success, but if the device
being deleted is opened just after it (but before the real deletion) it would
return failure.  (It shouldn't be open at all if this point is reached.)

Alasdair


