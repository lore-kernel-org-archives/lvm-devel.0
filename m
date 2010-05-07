From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 May 2010 01:27:36 +0100
Subject: [RFC PATCH] Reduce noise about missing devices.
In-Reply-To: <4BE353F7.3040305@redhat.com>
References: <87k4rsa8fd.fsf@twilight.int.mornfall.net.>
	<20100505190119.GF27027@agk-dp.fab.redhat.com>
	<4BE353F7.3040305@redhat.com>
Message-ID: <20100507002736.GQ27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 06, 2010 at 07:42:47PM -0400, Takahiro Yasui wrote:
> Do we need to access a broken device so many times? If lvm commands
> detects errors on a device a few times, my opinion is that lvm
> commands should quit accessing the device.
 
Agree.

Alasdair


